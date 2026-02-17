# Cohere API Integrator Skill

## Skill ID
`cohere-api-integrator`

## Category
🧠 AI Chatbot

## Responsibility
Secure API key handling, format AI request payload, parse AI response, and support streaming responses for Cohere API integration in chatbot applications.

## Inputs

```yaml
inputs:
  api_config:
    api_key: string             # Cohere API key (from env/secrets)
    endpoint: string            # API endpoint URL
    model: string               # "command" | "command-light" | "command-r"
    timeout: integer            # Request timeout in seconds
  request:
    message: string             # User message
    conversation_history: array # Previous messages
    system_prompt: string       # System instructions
    temperature: float          # 0.0-1.0
    max_tokens: integer         # Max response length
    stream: boolean             # Enable streaming
  context:
    user_id: string
    session_id: string
    metadata: object
```

## Outputs

```yaml
outputs:
  api_request_schema:
    endpoint: string
    headers: object
    body: object
    method: string
  api_response_parser:
    parsed_response: object
    extracted_text: string
    metadata: object
    tokens_used: integer
  security_strategy:
    key_storage: string
    encryption: boolean
    audit_logging: boolean
```

## Algorithm

1. **API Key Security**
   - Load API key from environment variables
   - Never log or expose API key
   - Validate key format before use
   - Implement key rotation support

2. **Request Formatting**
   - Build Cohere API request payload
   - Format conversation history
   - Apply system prompt
   - Set generation parameters

3. **Response Handling**
   - Parse API response
   - Extract generated text
   - Handle streaming responses
   - Capture metadata and usage

4. **Error Management**
   - Handle rate limits
   - Retry with exponential backoff
   - Parse error messages
   - Provide fallback responses

## API Request Schema

```yaml
cohere_request:
  endpoint: "https://api.cohere.ai/v1/chat"
  method: "POST"
  headers:
    Authorization: "Bearer {{API_KEY}}"
    Content-Type: "application/json"
    X-Client-Name: "todo-chatbot"
  body:
    message: "{{USER_MESSAGE}}"
    model: "{{MODEL}}"
    preamble: "{{SYSTEM_PROMPT}}"
    chat_history: [
      {
        role: "USER",
        message: "{{PREVIOUS_USER_MESSAGE}}"
      },
      {
        role: "CHATBOT",
        message: "{{PREVIOUS_BOT_MESSAGE}}"
      }
    ]
    temperature: {{TEMPERATURE}}
    max_tokens: {{MAX_TOKENS}}
    stream: {{STREAM_ENABLED}}
    conversation_id: "{{SESSION_ID}}"
```

## Request Builder Implementation

```typescript
interface CohereRequest {
  message: string;
  model: string;
  preamble?: string;
  chat_history?: Array<{role: string; message: string}>;
  temperature?: number;
  max_tokens?: number;
  stream?: boolean;
  conversation_id?: string;
}

function buildCohereRequest(
  userMessage: string,
  conversationHistory: Array<{role: string; content: string}>,
  systemPrompt: string,
  options: {
    model?: string;
    temperature?: number;
    maxTokens?: number;
    stream?: boolean;
    sessionId?: string;
  } = {}
): CohereRequest {
  // Format conversation history for Cohere
  const chatHistory = conversationHistory.map(msg => ({
    role: msg.role === 'user' ? 'USER' : 'CHATBOT',
    message: msg.content
  }));

  return {
    message: userMessage,
    model: options.model || 'command-r',
    preamble: systemPrompt,
    chat_history: chatHistory,
    temperature: options.temperature ?? 0.7,
    max_tokens: options.maxTokens ?? 1000,
    stream: options.stream ?? false,
    conversation_id: options.sessionId
  };
}
```

## Response Parser Implementation

```typescript
interface CohereResponse {
  text: string;
  generation_id: string;
  conversation_id?: string;
  meta?: {
    billed_units?: {
      input_tokens: number;
      output_tokens: number;
    };
  };
}

interface ParsedResponse {
  text: string;
  generationId: string;
  conversationId?: string;
  tokensUsed: {
    input: number;
    output: number;
    total: number;
  };
  metadata: object;
}

function parseCohereResponse(response: CohereResponse): ParsedResponse {
  const inputTokens = response.meta?.billed_units?.input_tokens || 0;
  const outputTokens = response.meta?.billed_units?.output_tokens || 0;

  return {
    text: response.text,
    generationId: response.generation_id,
    conversationId: response.conversation_id,
    tokensUsed: {
      input: inputTokens,
      output: outputTokens,
      total: inputTokens + outputTokens
    },
    metadata: response.meta || {}
  };
}
```

## Streaming Response Handler

```typescript
async function handleStreamingResponse(
  response: Response,
  onChunk: (text: string) => void,
  onComplete: (fullText: string) => void,
  onError: (error: Error) => void
): Promise<void> {
  const reader = response.body?.getReader();
  const decoder = new TextDecoder();
  let fullText = '';

  try {
    while (true) {
      const { done, value } = await reader!.read();

      if (done) {
        onComplete(fullText);
        break;
      }

      const chunk = decoder.decode(value, { stream: true });
      const lines = chunk.split('\n').filter(line => line.trim());

      for (const line of lines) {
        if (line.startsWith('data: ')) {
          const data = JSON.parse(line.slice(6));

          if (data.event_type === 'text-generation') {
            const text = data.text;
            fullText += text;
            onChunk(text);
          }
        }
      }
    }
  } catch (error) {
    onError(error as Error);
  }
}
```

## Security Strategy

```yaml
api_key_management:
  storage:
    method: "environment_variables"
    variable_name: "COHERE_API_KEY"
    fallback: "kubernetes_secret"

  kubernetes_secret:
    name: "cohere-api-credentials"
    key: "api-key"
    namespace: "production"

  access_control:
    - "Never log API key"
    - "Never return API key in responses"
    - "Never commit API key to version control"
    - "Rotate keys every 90 days"

  validation:
    format: "^[a-zA-Z0-9-_]{40,}$"
    test_endpoint: "https://api.cohere.ai/v1/check-api-key"

encryption:
  in_transit: "TLS 1.3"
  at_rest: "AES-256"

audit_logging:
  log_requests: true
  log_responses: true
  exclude_fields: ["api_key", "authorization"]
  retention: "90 days"
```

## Error Handling

```yaml
error_scenarios:
  rate_limit_exceeded:
    status_code: 429
    error_message: "Rate limit exceeded"
    retry_strategy:
      max_retries: 3
      backoff: "exponential"
      initial_delay: 1000
      max_delay: 10000
    fallback: "Queue request for later processing"

  invalid_api_key:
    status_code: 401
    error_message: "Invalid API key"
    retry_strategy: "none"
    fallback: "Return error to user, alert admin"

  model_overloaded:
    status_code: 503
    error_message: "Model temporarily unavailable"
    retry_strategy:
      max_retries: 2
      backoff: "exponential"
      initial_delay: 2000
    fallback: "Use fallback model or cached response"

  timeout:
    error_type: "TIMEOUT"
    retry_strategy:
      max_retries: 1
      timeout: 30000
    fallback: "Return timeout message to user"

  invalid_request:
    status_code: 400
    error_message: "Invalid request format"
    retry_strategy: "none"
    fallback: "Log error, return user-friendly message"
```

## Retry Logic Implementation

```typescript
async function callCohereWithRetry(
  request: CohereRequest,
  maxRetries: number = 3
): Promise<CohereResponse> {
  let lastError: Error;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch('https://api.cohere.ai/v1/chat', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.COHERE_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(request)
      });

      if (response.status === 429) {
        // Rate limit - exponential backoff
        const delay = Math.min(1000 * Math.pow(2, attempt), 10000);
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }

      if (!response.ok) {
        throw new Error(`Cohere API error: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      lastError = error as Error;

      if (attempt < maxRetries) {
        const delay = 1000 * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError!;
}
```

## Usage Examples

```yaml
basic_chat:
  request:
    message: "What tasks do I have today?"
    model: "command-r"
    preamble: "You are a helpful todo assistant."

  response:
    text: "Let me check your tasks for today..."
    tokens_used: 45

streaming_chat:
  request:
    message: "Explain how to organize my tasks"
    model: "command-r"
    stream: true

  response:
    chunks: ["Here's", " how", " to", " organize", "..."]
    full_text: "Here's how to organize..."

with_history:
  request:
    message: "What about tomorrow?"
    chat_history:
      - role: "USER"
        message: "What tasks do I have today?"
      - role: "CHATBOT"
        message: "You have 3 tasks today..."

  response:
    text: "For tomorrow, you have..."
```

## Model Selection Guide

```yaml
models:
  command:
    description: "Most capable model"
    use_cases:
      - "Complex reasoning"
      - "Long conversations"
      - "Detailed responses"
    cost: "High"
    speed: "Slower"

  command-light:
    description: "Faster, lighter model"
    use_cases:
      - "Simple queries"
      - "Quick responses"
      - "High-volume requests"
    cost: "Low"
    speed: "Fast"

  command-r:
    description: "Balanced model with RAG support"
    use_cases:
      - "Todo management"
      - "Context-aware responses"
      - "Production chatbots"
    cost: "Medium"
    speed: "Medium"
    recommended: true
```

## Monitoring and Observability

```yaml
metrics:
  request_count:
    type: "counter"
    labels: ["model", "status_code"]

  request_duration:
    type: "histogram"
    labels: ["model"]
    buckets: [100, 500, 1000, 2000, 5000]

  tokens_used:
    type: "counter"
    labels: ["model", "type"]

  error_rate:
    type: "counter"
    labels: ["error_type"]

logging:
  request_log:
    level: "info"
    fields:
      - "user_id"
      - "session_id"
      - "model"
      - "message_length"
      - "timestamp"

  response_log:
    level: "info"
    fields:
      - "generation_id"
      - "tokens_used"
      - "duration_ms"
      - "status"

  error_log:
    level: "error"
    fields:
      - "error_type"
      - "error_message"
      - "retry_count"
      - "user_id"
```

## Validation Commands

```yaml
validation_commands:
  - command: "curl -X POST https://api.cohere.ai/v1/check-api-key -H 'Authorization: Bearer $COHERE_API_KEY'"
    description: "Validate API key"
    success_criteria: "HTTP 200 response"

  - command: "Test basic chat request"
    description: "Send test message to Cohere"
    success_criteria: "Receive valid response"

  - command: "Test streaming response"
    description: "Verify streaming functionality"
    success_criteria: "Receive chunked response"
```

## Integration Points

- **Depends On**: Environment configuration, secrets management
- **Next Skill**: `openai-agents-sdk-wrapper` (SDK abstraction)
- **Outputs To**: Chatbot backend service

## Performance Targets

- Request latency: < 2 seconds (non-streaming)
- First token latency: < 500ms (streaming)
- Error rate: < 1%
- Retry success rate: > 95%

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
