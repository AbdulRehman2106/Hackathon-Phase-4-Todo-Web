# OpenAI Agents SDK Wrapper Skill

## Skill ID
`openai-agents-sdk-wrapper`

## Category
🧠 AI Chatbot

## Responsibility
Abstract OpenAI Agents SDK logic, bridge via Cohere API, and maintain modular AI architecture for flexible AI provider integration.

## Inputs

```yaml
inputs:
  sdk_config:
    provider: string            # "cohere" | "openai" | "anthropic"
    model: string
    api_key: string
  agent_config:
    name: string
    instructions: string
    tools: array                # Available tools/functions
    temperature: float
    max_tokens: integer
  conversation:
    messages: array
    context: object
    user_id: string
```

## Outputs

```yaml
outputs:
  abstraction_layer_design:
    interface: string           # TypeScript interface definition
    implementation: string      # Provider-specific implementation
    adapter_pattern: string
  sdk_bridge_schema:
    request_mapping: object
    response_mapping: object
    tool_execution_flow: string
```

## Algorithm

1. **Provider Abstraction**
   - Define common AI agent interface
   - Implement provider-specific adapters
   - Support multiple AI providers
   - Enable provider switching

2. **Tool Integration**
   - Define tool schema
   - Map tools to provider format
   - Handle tool execution
   - Return tool results

3. **Conversation Management**
   - Maintain conversation state
   - Format messages for provider
   - Handle context windows
   - Manage conversation history

4. **Response Processing**
   - Parse provider responses
   - Extract tool calls
   - Format final response
   - Handle streaming

## Abstraction Layer Design

```typescript
// Core AI Agent Interface
interface AIAgent {
  name: string;
  instructions: string;
  tools: Tool[];

  chat(message: string, context: ConversationContext): Promise<AgentResponse>;
  streamChat(message: string, context: ConversationContext): AsyncGenerator<string>;
  executeTool(toolName: string, parameters: object): Promise<ToolResult>;
}

// Tool Definition
interface Tool {
  name: string;
  description: string;
  parameters: {
    type: string;
    properties: Record<string, ParameterSchema>;
    required: string[];
  };
  execute: (params: object) => Promise<ToolResult>;
}

// Conversation Context
interface ConversationContext {
  userId: string;
  sessionId: string;
  history: Message[];
  metadata: Record<string, any>;
}

// Agent Response
interface AgentResponse {
  text: string;
  toolCalls?: ToolCall[];
  metadata: {
    tokensUsed: number;
    model: string;
    provider: string;
  };
}

// Tool Call
interface ToolCall {
  id: string;
  name: string;
  parameters: object;
}

// Tool Result
interface ToolResult {
  success: boolean;
  data: any;
  error?: string;
}
```

## Provider Adapter Pattern

```typescript
// Base Provider Adapter
abstract class AIProviderAdapter implements AIAgent {
  protected config: ProviderConfig;

  constructor(config: ProviderConfig) {
    this.config = config;
  }

  abstract chat(message: string, context: ConversationContext): Promise<AgentResponse>;
  abstract streamChat(message: string, context: ConversationContext): AsyncGenerator<string>;
  abstract formatTools(tools: Tool[]): any;
  abstract parseResponse(response: any): AgentResponse;
}

// Cohere Adapter Implementation
class CohereAdapter extends AIProviderAdapter {
  async chat(message: string, context: ConversationContext): Promise<AgentResponse> {
    const cohereRequest = {
      message: message,
      model: this.config.model,
      preamble: this.config.instructions,
      chat_history: this.formatHistory(context.history),
      tools: this.formatTools(this.config.tools)
    };

    const response = await this.callCohereAPI(cohereRequest);
    return this.parseResponse(response);
  }

  formatTools(tools: Tool[]): any[] {
    return tools.map(tool => ({
      name: tool.name,
      description: tool.description,
      parameter_definitions: tool.parameters.properties
    }));
  }

  parseResponse(response: any): AgentResponse {
    return {
      text: response.text,
      toolCalls: response.tool_calls?.map(tc => ({
        id: tc.id,
        name: tc.name,
        parameters: tc.parameters
      })),
      metadata: {
        tokensUsed: response.meta?.billed_units?.total_tokens || 0,
        model: this.config.model,
        provider: 'cohere'
      }
    };
  }

  private formatHistory(messages: Message[]): any[] {
    return messages.map(msg => ({
      role: msg.role === 'user' ? 'USER' : 'CHATBOT',
      message: msg.content
    }));
  }

  private async callCohereAPI(request: any): Promise<any> {
    const response = await fetch('https://api.cohere.ai/v1/chat', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.config.apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(request)
    });

    return await response.json();
  }
}

// OpenAI Adapter Implementation (for comparison)
class OpenAIAdapter extends AIProviderAdapter {
  async chat(message: string, context: ConversationContext): Promise<AgentResponse> {
    const openaiRequest = {
      model: this.config.model,
      messages: [
        { role: 'system', content: this.config.instructions },
        ...this.formatHistory(context.history),
        { role: 'user', content: message }
      ],
      tools: this.formatTools(this.config.tools)
    };

    const response = await this.callOpenAIAPI(openaiRequest);
    return this.parseResponse(response);
  }

  formatTools(tools: Tool[]): any[] {
    return tools.map(tool => ({
      type: 'function',
      function: {
        name: tool.name,
        description: tool.description,
        parameters: tool.parameters
      }
    }));
  }

  parseResponse(response: any): AgentResponse {
    const message = response.choices[0].message;

    return {
      text: message.content || '',
      toolCalls: message.tool_calls?.map(tc => ({
        id: tc.id,
        name: tc.function.name,
        parameters: JSON.parse(tc.function.arguments)
      })),
      metadata: {
        tokensUsed: response.usage.total_tokens,
        model: this.config.model,
        provider: 'openai'
      }
    };
  }

  private formatHistory(messages: Message[]): any[] {
    return messages.map(msg => ({
      role: msg.role,
      content: msg.content
    }));
  }

  private async callOpenAIAPI(request: any): Promise<any> {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.config.apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(request)
    });

    return await response.json();
  }
}
```

## Agent Factory

```typescript
class AIAgentFactory {
  static createAgent(
    provider: 'cohere' | 'openai' | 'anthropic',
    config: AgentConfig
  ): AIAgent {
    const providerConfig: ProviderConfig = {
      provider,
      model: config.model,
      apiKey: this.getAPIKey(provider),
      instructions: config.instructions,
      tools: config.tools
    };

    switch (provider) {
      case 'cohere':
        return new CohereAdapter(providerConfig);
      case 'openai':
        return new OpenAIAdapter(providerConfig);
      case 'anthropic':
        return new AnthropicAdapter(providerConfig);
      default:
        throw new Error(`Unsupported provider: ${provider}`);
    }
  }

  private static getAPIKey(provider: string): string {
    const envVar = `${provider.toUpperCase()}_API_KEY`;
    const apiKey = process.env[envVar];

    if (!apiKey) {
      throw new Error(`${envVar} not set`);
    }

    return apiKey;
  }
}
```

## Tool Execution Flow

```typescript
class AgentOrchestrator {
  private agent: AIAgent;
  private tools: Map<string, Tool>;

  constructor(agent: AIAgent) {
    this.agent = agent;
    this.tools = new Map(agent.tools.map(t => [t.name, t]));
  }

  async processMessage(
    message: string,
    context: ConversationContext
  ): Promise<string> {
    let response = await this.agent.chat(message, context);

    // Handle tool calls
    while (response.toolCalls && response.toolCalls.length > 0) {
      const toolResults = await this.executeTools(response.toolCalls);

      // Add tool results to context
      context.history.push({
        role: 'assistant',
        content: response.text,
        toolCalls: response.toolCalls
      });

      context.history.push({
        role: 'tool',
        content: JSON.stringify(toolResults)
      });

      // Get next response with tool results
      response = await this.agent.chat('', context);
    }

    return response.text;
  }

  private async executeTools(toolCalls: ToolCall[]): Promise<ToolResult[]> {
    const results: ToolResult[] = [];

    for (const call of toolCalls) {
      const tool = this.tools.get(call.name);

      if (!tool) {
        results.push({
          success: false,
          data: null,
          error: `Tool ${call.name} not found`
        });
        continue;
      }

      try {
        const result = await tool.execute(call.parameters);
        results.push(result);
      } catch (error) {
        results.push({
          success: false,
          data: null,
          error: (error as Error).message
        });
      }
    }

    return results;
  }
}
```

## Todo Management Tools Example

```typescript
// Define Todo Management Tools
const todoTools: Tool[] = [
  {
    name: 'create_todo',
    description: 'Create a new todo item',
    parameters: {
      type: 'object',
      properties: {
        title: {
          type: 'string',
          description: 'The title of the todo'
        },
        description: {
          type: 'string',
          description: 'Optional description'
        },
        due_date: {
          type: 'string',
          description: 'Due date in ISO format'
        }
      },
      required: ['title']
    },
    execute: async (params: any) => {
      // Call Todo API
      const response = await fetch('/api/todos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(params)
      });

      const todo = await response.json();

      return {
        success: true,
        data: todo
      };
    }
  },
  {
    name: 'list_todos',
    description: 'List all todos for the user',
    parameters: {
      type: 'object',
      properties: {
        status: {
          type: 'string',
          enum: ['all', 'pending', 'completed'],
          description: 'Filter by status'
        }
      },
      required: []
    },
    execute: async (params: any) => {
      const status = params.status || 'all';
      const response = await fetch(`/api/todos?status=${status}`);
      const todos = await response.json();

      return {
        success: true,
        data: todos
      };
    }
  },
  {
    name: 'update_todo',
    description: 'Update an existing todo',
    parameters: {
      type: 'object',
      properties: {
        id: {
          type: 'string',
          description: 'Todo ID'
        },
        title: {
          type: 'string',
          description: 'New title'
        },
        completed: {
          type: 'boolean',
          description: 'Mark as completed'
        }
      },
      required: ['id']
    },
    execute: async (params: any) => {
      const { id, ...updates } = params;
      const response = await fetch(`/api/todos/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates)
      });

      const todo = await response.json();

      return {
        success: true,
        data: todo
      };
    }
  },
  {
    name: 'delete_todo',
    description: 'Delete a todo item',
    parameters: {
      type: 'object',
      properties: {
        id: {
          type: 'string',
          description: 'Todo ID to delete'
        }
      },
      required: ['id']
    },
    execute: async (params: any) => {
      await fetch(`/api/todos/${params.id}`, {
        method: 'DELETE'
      });

      return {
        success: true,
        data: { deleted: true }
      };
    }
  }
];
```

## Usage Example

```typescript
// Initialize agent
const agent = AIAgentFactory.createAgent('cohere', {
  name: 'TodoAssistant',
  model: 'command-r',
  instructions: `You are a helpful todo management assistant.
    Help users create, update, and manage their todos.
    Always confirm actions before executing them.`,
  tools: todoTools,
  temperature: 0.7,
  maxTokens: 1000
});

// Create orchestrator
const orchestrator = new AgentOrchestrator(agent);

// Process user message
const context: ConversationContext = {
  userId: 'user123',
  sessionId: 'session456',
  history: [],
  metadata: {}
};

const response = await orchestrator.processMessage(
  'Create a todo to buy groceries tomorrow',
  context
);

console.log(response);
// Output: "I've created a todo for you to buy groceries tomorrow.
//          The task has been added to your list."
```

## Provider Comparison

```yaml
providers:
  cohere:
    strengths:
      - "Native tool/function calling support"
      - "Good for conversational AI"
      - "Competitive pricing"
    limitations:
      - "Smaller model selection"
    best_for: "Todo chatbot, conversational apps"

  openai:
    strengths:
      - "Most mature function calling"
      - "Wide model selection"
      - "Excellent documentation"
    limitations:
      - "Higher cost"
    best_for: "Complex reasoning, multi-step tasks"

  anthropic:
    strengths:
      - "Strong reasoning capabilities"
      - "Large context windows"
      - "Tool use support"
    limitations:
      - "Different API patterns"
    best_for: "Complex analysis, long conversations"
```

## Migration Strategy

```yaml
provider_migration:
  step_1_abstraction:
    - "Implement provider abstraction layer"
    - "Define common interfaces"
    - "Create adapter pattern"

  step_2_dual_support:
    - "Support multiple providers simultaneously"
    - "A/B test different providers"
    - "Compare performance and cost"

  step_3_gradual_migration:
    - "Route percentage of traffic to new provider"
    - "Monitor quality and performance"
    - "Gradually increase traffic"

  step_4_complete_switch:
    - "Migrate all traffic to new provider"
    - "Keep old provider as fallback"
    - "Remove old provider after validation"
```

## Testing Strategy

```yaml
unit_tests:
  - "Test each adapter independently"
  - "Mock provider API responses"
  - "Verify tool execution"
  - "Test error handling"

integration_tests:
  - "Test with real provider APIs"
  - "Verify tool calling flow"
  - "Test conversation continuity"
  - "Validate response parsing"

provider_compatibility_tests:
  - "Test same conversation across providers"
  - "Verify consistent behavior"
  - "Compare response quality"
  - "Measure performance differences"
```

## Integration Points

- **Depends On**: `cohere-api-integrator` (Cohere implementation)
- **Next Skill**: `ai-intent-parser` (intent classification)
- **Outputs To**: Chatbot backend service

## Performance Targets

- Provider switching: < 100ms overhead
- Tool execution: < 500ms per tool
- Response latency: < 2 seconds
- Abstraction overhead: < 5%

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
