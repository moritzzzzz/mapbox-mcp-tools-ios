//
//  ContentView.swift
//  ios_mapbox_mcp_wrapper
//
//  Created by Moritz Foerster on 19.12.25.
//

import SwiftUI
import MapboxMaps
import MapboxMCPTools

struct ContentView: View {
    @State private var mcpTools: MapboxMCPTools?
    @State private var statusMessage: String = "Initializing..."
    @State private var toolCount: Int = 0

    // Chat state
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var isChatVisible: Bool = true

    // Services
    private let claudeAPI = ClaudeAPIService()

    var body: some View {
        ZStack {
            // Map view using UIViewRepresentable wrapper
            MapboxMapView(mcpTools: $mcpTools, onInitialized: { tools in
                initializeMCPTools(tools: tools)
            })
            .ignoresSafeArea()

            // Chat panel overlay
            VStack {
                Spacer()

                if isChatVisible {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Claude Map Assistant")
                                    .font(.headline)
                                Text("\(toolCount) tools available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button(action: {
                                withAnimation {
                                    isChatVisible = false
                                }
                            }) {
                                Image(systemName: "chevron.down")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))

                        Divider()

                        // Chat messages and input
                        ChatView(
                            messages: $messages,
                            inputText: $inputText,
                            isLoading: $isLoading,
                            onSendMessage: sendMessage
                        )
                        .frame(height: 400)
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .shadow(radius: 10)
                    .transition(.move(edge: .bottom))
                } else {
                    // Minimized chat button
                    HStack {
                        Button(action: {
                            withAnimation {
                                isChatVisible = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Chat with Claude")
                                Image(systemName: "chevron.up")
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
            }

            // Status indicator (top)
            VStack {
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(.blue)
                    Text(statusMessage)
                        .font(.caption)
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding()

                Spacer()
            }
        }
        .onAppear {
            // Add welcome message
            messages.append(ChatMessage(
                role: .assistant,
                content: "Hi! I'm Claude, and I can help you control this map. Try asking me to:\n• Pan to a specific city or location\n• Add markers for multiple places\n• Draw routes between locations\n• Add polygons for areas\n• Change the map style\n\nWhat would you like to do?"
            ))
        }
    }

    // MARK: - MCP Tools Integration

    private func initializeMCPTools(tools: MapboxMCPTools) {
        // MCP Tools instance is already created by MapboxMapView
        self.mcpTools = tools

        // Get tool definitions for Claude API
        let toolDefinitions = tools.getToolsForLLM()
        toolCount = toolDefinitions.count

        // Print tool definitions (for debugging)
        print("📍 MapboxMCPTools initialized with \(toolCount) tools:")
        for tool in toolDefinitions {
            print("  - \(tool.name): \(tool.description)")
        }

        statusMessage = "✅ Ready - Chat with Claude to control the map"
    }

    // MARK: - Chat & Claude API Integration

    private func sendMessage() {
        guard !inputText.isEmpty, let mcpTools = mcpTools else { return }

        let userMessage = inputText
        inputText = ""

        // Add user message to chat
        messages.append(ChatMessage(role: .user, content: userMessage))
        isLoading = true
        statusMessage = "🤔 Claude is thinking..."

        Task {
            do {
                // Get tool definitions
                let tools = mcpTools.getToolsForLLM()

                // Send message to Claude API
                let response = try await claudeAPI.sendMessage(
                    userMessage: userMessage,
                    conversationHistory: messages,
                    tools: tools
                )

                await MainActor.run {
                    handleClaudeResponse(response)
                }

            } catch {
                await MainActor.run {
                    isLoading = false
                    statusMessage = "❌ Error: \(error.localizedDescription)"
                    messages.append(ChatMessage(
                        role: .assistant,
                        content: "Sorry, I encountered an error: \(error.localizedDescription)"
                    ))
                }
            }
        }
    }

    private func handleClaudeResponse(_ response: ClaudeResponse) {
        var assistantMessage = ""
        var toolResults: [String] = []

        // Process each content block
        for block in response.content {
            if let text = block.text {
                assistantMessage += text
            } else if block.isToolUse, let toolName = block.name, let input = block.input {
                // Execute the tool - properly unwrap AnyCodable parameters
                let params = input.toAnyDictionary()
                statusMessage = "🔧 Executing: \(toolName)..."

                print("🔧 Executing tool: \(toolName)")
                print("📋 Parameters: \(params)")

                if let mcpTools = mcpTools {
                    let result = mcpTools.executeTool(name: toolName, params: params)

                    switch result {
                    case .success(let data):
                        let msg = data["message"] as? String ?? "Tool executed successfully"
                        toolResults.append("✅ \(toolName): \(msg)")
                        print("✅ Tool executed: \(toolName) - \(msg)")

                    case .error(let errorMsg):
                        toolResults.append("❌ \(toolName) failed: \(errorMsg)")
                        print("❌ Tool failed: \(toolName) - \(errorMsg)")
                    }
                }
            }
        }

        // Combine text response with tool results
        if !toolResults.isEmpty {
            if !assistantMessage.isEmpty {
                assistantMessage += "\n\n"
            }
            assistantMessage += toolResults.joined(separator: "\n")
        }

        // Add assistant's response to chat
        if !assistantMessage.isEmpty {
            messages.append(ChatMessage(role: .assistant, content: assistantMessage))
        }

        isLoading = false
        statusMessage = "✅ Ready"
    }
}

#Preview {
    ContentView()
}

// MARK: - MapboxMapView UIViewRepresentable

struct MapboxMapView: UIViewRepresentable {
    @Binding var mcpTools: MapboxMCPTools?
    let onInitialized: (MapboxMCPTools) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(mcpTools: $mcpTools, onInitialized: onInitialized)
    }

    func makeUIView(context: Context) -> MapView {
        // Create MapView with initial camera position
        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0),
            zoom: 2,
            bearing: 0,
            pitch: 0
        )

        let mapInitOptions = MapInitOptions(
            cameraOptions: cameraOptions,
            styleURI: .streets
        )

        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)

        // Initialize MCP Tools once the map is created
        context.coordinator.initializeTools(with: mapView)

        return mapView
    }

    func updateUIView(_ mapView: MapView, context: Context) {
        // Update the view if needed
    }

    class Coordinator {
        @Binding var mcpTools: MapboxMCPTools?
        let onInitialized: (MapboxMCPTools) -> Void

        init(mcpTools: Binding<MapboxMCPTools?>, onInitialized: @escaping (MapboxMCPTools) -> Void) {
            self._mcpTools = mcpTools
            self.onInitialized = onInitialized
        }

        func initializeTools(with mapView: MapView) {
            DispatchQueue.main.async {
                let tools = MapboxMCPTools(mapView: mapView)
                self.mcpTools = tools
                self.onInitialized(tools)
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
