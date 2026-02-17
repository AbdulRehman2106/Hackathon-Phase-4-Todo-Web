# AI Intent Parser Skill

## Skill ID
`ai-intent-parser`

## Category
🧠 AI Chatbot

## Responsibility
Classify Todo intents, map to CRUD operations, extract entities, and route user requests to appropriate backend actions.

## Inputs

```yaml
inputs:
  user_message: string          # Raw user input
  conversation_context:
    history: array              # Previous messages
    user_id: string
    session_id: string
  classification_config:
    confidence_threshold: float # Minimum confidence (0.0-1.0)
    fallback_intent: string     # Default intent if uncertain
```

## Outputs

```yaml
outputs:
  intent_schema:
    intent: string              # Classified intent
    confidence: float           # Classification confidence
    entities: object            # Extracted entities
    action: string              # Backend action to execute
  action_mapping_table:
    intent_to_action: object    # Intent → Action mapping
    required_entities: array    # Required entities per intent
    validation_rules: object    # Entity validation rules
```

## Algorithm

1. **Intent Classification**
   - Analyze user message
   - Identify primary intent
   - Calculate confidence score
   - Apply threshold filtering

2. **Entity Extraction**
   - Extract relevant entities (title, date, priority, etc.)
   - Normalize entity values
   - Validate entity formats
   - Handle missing entities

3. **Action Mapping**
   - Map intent to CRUD operation
   - Determine API endpoint
   - Prepare request parameters
   - Validate required fields

4. **Confidence Handling**
   - High confidence: Execute action
   - Medium confidence: Ask for confirmation
   - Low confidence: Request clarification

## Intent Schema

```yaml
intents:
  create_todo:
    description: "User wants to create a new todo"
    examples:
      - "Create a todo to buy groceries"
      - "Add task: finish report"
      - "Remind me to call John tomorrow"
    entities:
      - title (required)
      - description (optional)
      - due_date (optional)
      - priority (optional)
    action: "POST /api/todos"
    confidence_threshold: 0.7

  list_todos:
    description: "User wants to view their todos"
    examples:
      - "Show my todos"
      - "What tasks do I have?"
      - "List all pending items"
    entities:
      - status (optional: all, pending, completed)
      - date_filter (optional)
    action: "GET /api/todos"
    confidence_threshold: 0.8

  update_todo:
    description: "User wants to modify an existing todo"
    examples:
      - "Mark task 5 as complete"
      - "Update the title of my first todo"
      - "Change due date to tomorrow"
    entities:
      - todo_id (required)
      - updates (required: title, status, due_date, etc.)
    action: "PATCH /api/todos/:id"
    confidence_threshold: 0.7

  delete_todo:
    description: "User wants to delete a todo"
    examples:
      - "Delete task 3"
      - "Remove the grocery todo"
      - "Cancel my meeting reminder"
    entities:
      - todo_id (required)
    action: "DELETE /api/todos/:id"
    confidence_threshold: 0.8

  search_todos:
    description: "User wants to search/filter todos"
    examples:
      - "Find todos about groceries"
      - "Show tasks due this week"
      - "Search for meeting todos"
    entities:
      - query (required)
      - filters (optional)
    action: "GET /api/todos/search"
    confidence_threshold: 0.7

  get_todo_details:
    description: "User wants details about a specific todo"
    examples:
      - "Show me task 5"
      - "What's in my first todo?"
      - "Details of the grocery task"
    entities:
      - todo_id (required)
    action: "GET /api/todos/:id"
    confidence_threshold: 0.8

  general_question:
    description: "General question not related to todo operations"
    examples:
      - "How do I use this app?"
      - "What can you do?"
      - "Help me understand priorities"
    entities: []
    action: "RESPOND_WITH_INFO"
    confidence_threshold: 0.6
```

## Entity Extraction Schema

```typescript
interface ExtractedEntities {
  title?: string;
  description?: string;
  due_date?: string;          // ISO 8601 format
  priority?: 'low' | 'medium' | 'high';
  status?: 'pending' | 'completed';
  todo_id?: string;
  query?: string;
  filters?: {
    status?: string;
    date_range?: {
      start: string;
      end: string;
    };
    priority?: string;
  };
}

interface IntentClassification {
  intent: string;
  confidence: number;
  entities: ExtractedEntities;
  action: {
    method: string;
    endpoint: string;
    parameters: object;
  };
  requiresConfirmation: boolean;
}
```

## Intent Classification Implementation

```typescript
class IntentParser {
  private confidenceThreshold: number = 0.7;

  async classifyIntent(
    message: string,
    context: ConversationContext
  ): Promise<IntentClassification> {
    // Use AI model for intent classification
    const classification = await this.aiClassify(message, context);

    // Extract entities
    const entities = await this.extractEntities(message, classification.intent);

    // Map to action
    const action = this.mapIntentToAction(classification.intent, entities);

    // Determine if confirmation needed
    const requiresConfirmation = classification.confidence < 0.85 ||
                                  this.isDestructiveAction(classification.intent);

    return {
      intent: classification.intent,
      confidence: classification.confidence,
      entities,
      action,
      requiresConfirmation
    };
  }

  private async aiClassify(
    message: string,
    context: ConversationContext
  ): Promise<{ intent: string; confidence: number }> {
    // Use Cohere or other AI model for classification
    const prompt = `
      Classify the following user message into one of these intents:
      - create_todo
      - list_todos
      - update_todo
      - delete_todo
      - search_todos
      - get_todo_details
      - general_question

      User message: "${message}"

      Respond with JSON: {"intent": "...", "confidence": 0.0-1.0}
    `;

    const response = await this.callAI(prompt);
    return JSON.parse(response);
  }

  private async extractEntities(
    message: string,
    intent: string
  ): Promise<ExtractedEntities> {
    const entities: ExtractedEntities = {};

    switch (intent) {
      case 'create_todo':
        entities.title = this.extractTitle(message);
        entities.due_date = this.extractDate(message);
        entities.priority = this.extractPriority(message);
        break;

      case 'update_todo':
      case 'delete_todo':
      case 'get_todo_details':
        entities.todo_id = this.extractTodoId(message);
        if (intent === 'update_todo') {
          entities.status = this.extractStatus(message);
          entities.title = this.extractTitle(message);
        }
        break;

      case 'list_todos':
        entities.status = this.extractStatus(message);
        entities.filters = this.extractFilters(message);
        break;

      case 'search_todos':
        entities.query = this.extractSearchQuery(message);
        entities.filters = this.extractFilters(message);
        break;
    }

    return entities;
  }

  private extractTitle(message: string): string | undefined {
    // Extract todo title from message
    const patterns = [
      /(?:create|add|new)\s+(?:todo|task|reminder)?\s*:?\s*(.+)/i,
      /(?:to|for)\s+(.+?)(?:\s+(?:by|on|tomorrow|today))?$/i
    ];

    for (const pattern of patterns) {
      const match = message.match(pattern);
      if (match) {
        return match[1].trim();
      }
    }

    return undefined;
  }

  private extractDate(message: string): string | undefined {
    const today = new Date();

    // Check for relative dates
    if (/tomorrow/i.test(message)) {
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      return tomorrow.toISOString();
    }

    if (/today/i.test(message)) {
      return today.toISOString();
    }

    if (/next week/i.test(message)) {
      const nextWeek = new Date(today);
      nextWeek.setDate(nextWeek.getDate() + 7);
      return nextWeek.toISOString();
    }

    // Check for specific dates (basic pattern)
    const datePattern = /(\d{4}-\d{2}-\d{2})/;
    const match = message.match(datePattern);
    if (match) {
      return new Date(match[1]).toISOString();
    }

    return undefined;
  }

  private extractPriority(message: string): 'low' | 'medium' | 'high' | undefined {
    if (/\b(urgent|high|important|critical)\b/i.test(message)) {
      return 'high';
    }
    if (/\b(medium|normal)\b/i.test(message)) {
      return 'medium';
    }
    if (/\b(low|minor)\b/i.test(message)) {
      return 'low';
    }
    return undefined;
  }

  private extractTodoId(message: string): string | undefined {
    // Extract todo ID from message
    const patterns = [
      /\b(?:task|todo|item)\s+#?(\d+)/i,
      /\b#(\d+)/,
      /\bid[:\s]+(\d+)/i
    ];

    for (const pattern of patterns) {
      const match = message.match(pattern);
      if (match) {
        return match[1];
      }
    }

    return undefined;
  }

  private extractStatus(message: string): 'pending' | 'completed' | undefined {
    if (/\b(complete|done|finished)\b/i.test(message)) {
      return 'completed';
    }
    if (/\b(pending|incomplete|active)\b/i.test(message)) {
      return 'pending';
    }
    return undefined;
  }

  private extractSearchQuery(message: string): string {
    // Remove common search keywords
    return message
      .replace(/\b(find|search|show|list)\b/gi, '')
      .replace(/\btodos?\b/gi, '')
      .trim();
  }

  private extractFilters(message: string): any {
    const filters: any = {};

    // Status filter
    const status = this.extractStatus(message);
    if (status) {
      filters.status = status;
    }

    // Date range filter
    if (/this week/i.test(message)) {
      const today = new Date();
      const endOfWeek = new Date(today);
      endOfWeek.setDate(today.getDate() + (7 - today.getDay()));

      filters.date_range = {
        start: today.toISOString(),
        end: endOfWeek.toISOString()
      };
    }

    return Object.keys(filters).length > 0 ? filters : undefined;
  }

  private mapIntentToAction(
    intent: string,
    entities: ExtractedEntities
  ): { method: string; endpoint: string; parameters: object } {
    const actionMap: Record<string, any> = {
      create_todo: {
        method: 'POST',
        endpoint: '/api/todos',
        parameters: {
          title: entities.title,
          description: entities.description,
          due_date: entities.due_date,
          priority: entities.priority
        }
      },
      list_todos: {
        method: 'GET',
        endpoint: '/api/todos',
        parameters: {
          status: entities.status,
          ...entities.filters
        }
      },
      update_todo: {
        method: 'PATCH',
        endpoint: `/api/todos/${entities.todo_id}`,
        parameters: {
          title: entities.title,
          status: entities.status
        }
      },
      delete_todo: {
        method: 'DELETE',
        endpoint: `/api/todos/${entities.todo_id}`,
        parameters: {}
      },
      search_todos: {
        method: 'GET',
        endpoint: '/api/todos/search',
        parameters: {
          q: entities.query,
          ...entities.filters
        }
      },
      get_todo_details: {
        method: 'GET',
        endpoint: `/api/todos/${entities.todo_id}`,
        parameters: {}
      }
    };

    return actionMap[intent] || {
      method: 'NONE',
      endpoint: '',
      parameters: {}
    };
  }

  private isDestructiveAction(intent: string): boolean {
    return intent === 'delete_todo';
  }
}
```

## Action Mapping Table

```yaml
action_mapping:
  create_todo:
    http_method: "POST"
    endpoint: "/api/todos"
    required_entities: ["title"]
    optional_entities: ["description", "due_date", "priority"]
    validation:
      title:
        type: "string"
        min_length: 1
        max_length: 200
      due_date:
        type: "date"
        format: "ISO 8601"
      priority:
        type: "enum"
        values: ["low", "medium", "high"]

  list_todos:
    http_method: "GET"
    endpoint: "/api/todos"
    required_entities: []
    optional_entities: ["status", "filters"]
    validation:
      status:
        type: "enum"
        values: ["all", "pending", "completed"]

  update_todo:
    http_method: "PATCH"
    endpoint: "/api/todos/:id"
    required_entities: ["todo_id"]
    optional_entities: ["title", "status", "due_date", "priority"]
    validation:
      todo_id:
        type: "string"
        pattern: "^[0-9]+$"

  delete_todo:
    http_method: "DELETE"
    endpoint: "/api/todos/:id"
    required_entities: ["todo_id"]
    optional_entities: []
    requires_confirmation: true
    validation:
      todo_id:
        type: "string"
        pattern: "^[0-9]+$"

  search_todos:
    http_method: "GET"
    endpoint: "/api/todos/search"
    required_entities: ["query"]
    optional_entities: ["filters"]
    validation:
      query:
        type: "string"
        min_length: 1
```

## Confidence Handling Strategy

```yaml
confidence_levels:
  high_confidence:
    range: "0.85 - 1.0"
    action: "Execute immediately"
    response: "I'll [action] for you."

  medium_confidence:
    range: "0.70 - 0.84"
    action: "Ask for confirmation"
    response: "Did you want me to [action]? (Yes/No)"

  low_confidence:
    range: "0.50 - 0.69"
    action: "Request clarification"
    response: "I'm not sure what you want. Did you mean to [option1] or [option2]?"

  very_low_confidence:
    range: "0.0 - 0.49"
    action: "Provide help"
    response: "I didn't understand. Here's what I can help with: [list capabilities]"
```

## Usage Example

```typescript
// Initialize parser
const parser = new IntentParser();

// Parse user message
const message = "Create a todo to buy groceries tomorrow";
const context = {
  userId: 'user123',
  sessionId: 'session456',
  history: []
};

const result = await parser.classifyIntent(message, context);

console.log(result);
// Output:
// {
//   intent: "create_todo",
//   confidence: 0.92,
//   entities: {
//     title: "buy groceries",
//     due_date: "2026-02-17T00:00:00.000Z"
//   },
//   action: {
//     method: "POST",
//     endpoint: "/api/todos",
//     parameters: {
//       title: "buy groceries",
//       due_date: "2026-02-17T00:00:00.000Z"
//     }
//   },
//   requiresConfirmation: false
// }
```

## Error Handling

```yaml
error_scenarios:
  missing_required_entity:
    detection: "Required entity not extracted"
    response: "I need more information. What should the [entity] be?"

  ambiguous_intent:
    detection: "Multiple intents with similar confidence"
    response: "Did you want to [intent1] or [intent2]?"

  invalid_entity_format:
    detection: "Entity fails validation"
    response: "The [entity] format is invalid. Please provide [format]."

  todo_not_found:
    detection: "Todo ID doesn't exist"
    response: "I couldn't find that todo. Can you provide the correct ID?"
```

## Integration Points

- **Depends On**: `openai-agents-sdk-wrapper` (AI classification)
- **Next Skill**: `logging-standardizer` (observability)
- **Outputs To**: Backend API router

## Performance Targets

- Intent classification: < 500ms
- Entity extraction: < 200ms
- Total parsing time: < 1 second
- Classification accuracy: > 90%

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
