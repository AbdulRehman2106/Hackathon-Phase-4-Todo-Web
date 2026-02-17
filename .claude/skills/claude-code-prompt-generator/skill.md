# Claude Code Prompt Generator Skill

## Skill ID
`claude-code-prompt-generator`

## Category
🏗 Spec-Driven Development

## Responsibility
Convert task into executable Claude Code prompt, enforce no-manual-coding rule, generate validation prompts, and ensure AI-driven implementation.

## Inputs

```yaml
inputs:
  task:
    id: string
    title: string
    description: string
    type: string
    component: string
    acceptance_criteria: array
    files_to_modify: array
    validation_steps: array
  context:
    feature_name: string
    spec_path: string
    plan_path: string
    infrastructure_path: string
  execution_mode: string        # "autonomous" | "guided" | "validation"
```

## Outputs

```yaml
outputs:
  executable_prompt:
    prompt: string
    context_files: array
    expected_outputs: array
    validation_criteria: array
  validation_prompt:
    prompt: string
    test_commands: array
    success_criteria: array
```

## Algorithm

1. **Task Analysis**
   - Parse task requirements
   - Identify required context
   - Determine implementation approach
   - Extract acceptance criteria

2. **Context Gathering**
   - Identify relevant files
   - Extract specification sections
   - Gather infrastructure details
   - Collect related tasks

3. **Prompt Construction**
   - Build clear, actionable prompt
   - Include all necessary context
   - Specify expected outputs
   - Define validation steps

4. **Validation Design**
   - Generate test commands
   - Define success criteria
   - Create verification prompts
   - Ensure completeness

## Prompt Template Structure

```yaml
prompt_structure:
  header:
    - "Task ID and Title"
    - "Component and Type"
    - "Priority and Complexity"

  context:
    - "Feature Overview"
    - "Related Specifications"
    - "Infrastructure Requirements"
    - "Dependencies"

  requirements:
    - "Detailed Task Description"
    - "Acceptance Criteria"
    - "Files to Modify"
    - "Technical Constraints"

  implementation_guidance:
    - "Approach Recommendations"
    - "Code Standards"
    - "Security Considerations"
    - "Performance Requirements"

  validation:
    - "Validation Steps"
    - "Test Commands"
    - "Success Criteria"
    - "Rollback Procedure"

  output_specification:
    - "Expected Files"
    - "Code Structure"
    - "Documentation Requirements"
```

## Executable Prompt Template

```markdown
# Task: {{TASK_TITLE}}

**Task ID:** {{TASK_ID}}
**Component:** {{COMPONENT}}
**Type:** {{TASK_TYPE}}
**Priority:** {{PRIORITY}}
**Estimated Hours:** {{ESTIMATED_HOURS}}

## Context

### Feature Overview
{{FEATURE_NAME}} - {{FEATURE_DESCRIPTION}}

**Specification:** `{{SPEC_PATH}}`
**Plan:** `{{PLAN_PATH}}`
**Infrastructure:** `{{INFRASTRUCTURE_PATH}}`

### Dependencies
This task depends on:
{{#each DEPENDENCIES}}
- {{this.id}}: {{this.title}} (Status: {{this.status}})
{{/each}}

### Related Files
{{#each RELATED_FILES}}
- `{{this.path}}` - {{this.description}}
{{/each}}

## Requirements

### Task Description
{{TASK_DESCRIPTION}}

### Acceptance Criteria
{{#each ACCEPTANCE_CRITERIA}}
- [ ] {{this}}
{{/each}}

### Files to Modify
{{#each FILES_TO_MODIFY}}
- `{{this}}`
{{/each}}

### Technical Constraints
{{#each CONSTRAINTS}}
- {{this}}
{{/each}}

## Implementation Guidance

### Approach
{{IMPLEMENTATION_APPROACH}}

### Code Standards
- Follow project coding conventions (see `.specify/memory/constitution.md`)
- Use TypeScript/Python type hints
- Write self-documenting code
- Add comments only where logic is non-obvious
- Follow security best practices

### Security Considerations
{{#each SECURITY_REQUIREMENTS}}
- {{this}}
{{/each}}

### Performance Requirements
{{#each PERFORMANCE_REQUIREMENTS}}
- {{this}}
{{/each}}

## Validation

### Validation Steps
{{#each VALIDATION_STEPS}}
{{@index}}. {{this}}
{{/each}}

### Test Commands
```bash
{{#each TEST_COMMANDS}}
# {{this.description}}
{{this.command}}

{{/each}}
```

### Success Criteria
{{#each SUCCESS_CRITERIA}}
- {{this}}
{{/each}}

## Expected Outputs

### Files to Create/Modify
{{#each EXPECTED_FILES}}
- `{{this.path}}` - {{this.description}}
{{/each}}

### Code Structure
{{CODE_STRUCTURE_DESCRIPTION}}

### Documentation
{{#if REQUIRES_DOCUMENTATION}}
- Update relevant documentation
- Add inline code comments where needed
- Update API documentation if applicable
{{/if}}

## Execution Instructions

1. Read the specification and plan documents
2. Review related files for context
3. Implement the solution following the guidance above
4. Run all validation steps
5. Verify all acceptance criteria are met
6. Commit changes with descriptive message

**Important:** Do not proceed to the next task until all acceptance criteria are verified.
```

## Prompt Generator Implementation

```typescript
interface Task {
  id: string;
  title: string;
  description: string;
  type: string;
  component: string;
  priority: string;
  complexity: string;
  estimated_hours: number;
  dependencies: string[];
  acceptance_criteria: string[];
  skills_required: string[];
  files_to_modify: string[];
  validation_steps: string[];
}

interface PromptContext {
  feature_name: string;
  spec_path: string;
  plan_path: string;
  infrastructure_path: string;
  related_files: Array<{ path: string; description: string }>;
  constraints: string[];
  security_requirements: string[];
  performance_requirements: string[];
}

class ClaudeCodePromptGenerator {
  generateExecutablePrompt(task: Task, context: PromptContext): string {
    const sections = [
      this.generateHeader(task),
      this.generateContext(task, context),
      this.generateRequirements(task),
      this.generateImplementationGuidance(task, context),
      this.generateValidation(task),
      this.generateExpectedOutputs(task),
      this.generateExecutionInstructions(task)
    ];

    return sections.join('\n\n');
  }

  private generateHeader(task: Task): string {
    return `# Task: ${task.title}

**Task ID:** ${task.id}
**Component:** ${task.component}
**Type:** ${task.type}
**Priority:** ${task.priority}
**Estimated Hours:** ${task.estimated_hours}`;
  }

  private generateContext(task: Task, context: PromptContext): string {
    let section = `## Context

### Feature Overview
${context.feature_name}

**Specification:** \`${context.spec_path}\`
**Plan:** \`${context.plan_path}\`
**Infrastructure:** \`${context.infrastructure_path}\``;

    if (task.dependencies.length > 0) {
      section += '\n\n### Dependencies\nThis task depends on:\n';
      task.dependencies.forEach(dep => {
        section += `- ${dep}\n`;
      });
    }

    if (context.related_files.length > 0) {
      section += '\n\n### Related Files\n';
      context.related_files.forEach(file => {
        section += `- \`${file.path}\` - ${file.description}\n`;
      });
    }

    return section;
  }

  private generateRequirements(task: Task): string {
    let section = `## Requirements

### Task Description
${task.description}

### Acceptance Criteria`;

    task.acceptance_criteria.forEach(criteria => {
      section += `\n- [ ] ${criteria}`;
    });

    section += '\n\n### Files to Modify';
    task.files_to_modify.forEach(file => {
      section += `\n- \`${file}\``;
    });

    return section;
  }

  private generateImplementationGuidance(task: Task, context: PromptContext): string {
    let section = `## Implementation Guidance

### Approach
${this.suggestApproach(task)}

### Code Standards
- Follow project coding conventions (see \`.specify/memory/constitution.md\`)
- Use TypeScript/Python type hints
- Write self-documenting code
- Add comments only where logic is non-obvious
- Follow security best practices`;

    if (context.security_requirements.length > 0) {
      section += '\n\n### Security Considerations';
      context.security_requirements.forEach(req => {
        section += `\n- ${req}`;
      });
    }

    if (context.performance_requirements.length > 0) {
      section += '\n\n### Performance Requirements';
      context.performance_requirements.forEach(req => {
        section += `\n- ${req}`;
      });
    }

    return section;
  }

  private generateValidation(task: Task): string {
    let section = `## Validation

### Validation Steps`;

    task.validation_steps.forEach((step, index) => {
      section += `\n${index + 1}. ${step}`;
    });

    section += '\n\n### Success Criteria';
    task.acceptance_criteria.forEach(criteria => {
      section += `\n- ${criteria}`;
    });

    return section;
  }

  private generateExpectedOutputs(task: Task): string {
    return `## Expected Outputs

### Files to Create/Modify
${task.files_to_modify.map(f => `- \`${f}\``).join('\n')}

### Documentation
- Update relevant documentation
- Add inline code comments where needed
- Update API documentation if applicable`;
  }

  private generateExecutionInstructions(task: Task): string {
    return `## Execution Instructions

1. Read the specification and plan documents
2. Review related files for context
3. Implement the solution following the guidance above
4. Run all validation steps
5. Verify all acceptance criteria are met
6. Commit changes with descriptive message

**Important:** Do not proceed to the next task until all acceptance criteria are verified.`;
  }

  private suggestApproach(task: Task): string {
    const approaches: Record<string, string> = {
      'implementation': 'Implement the feature incrementally, testing each component as you build.',
      'testing': 'Write tests that cover happy paths, edge cases, and error scenarios.',
      'deployment': 'Follow the deployment checklist and verify each step before proceeding.',
      'documentation': 'Document the "why" not just the "what". Include examples and use cases.'
    };

    return approaches[task.type] || 'Follow best practices for this type of task.';
  }

  generateValidationPrompt(task: Task): string {
    return `# Validation: ${task.title}

## Task ID
${task.id}

## Validation Checklist

### Acceptance Criteria
${task.acceptance_criteria.map(c => `- [ ] ${c}`).join('\n')}

### Validation Steps
${task.validation_steps.map((s, i) => `${i + 1}. ${s}`).join('\n')}

## Verification Commands

Run the following commands to verify the implementation:

\`\`\`bash
${task.validation_steps.map(s => `# ${s}\n# [Add specific command here]`).join('\n\n')}
\`\`\`

## Success Criteria

All of the following must be true:
${task.acceptance_criteria.map(c => `- ${c}`).join('\n')}

## If Validation Fails

1. Review the error messages
2. Check the implementation against requirements
3. Fix the issues
4. Re-run validation
5. Do not proceed until all criteria pass`;
  }
}
```

## Usage Examples

### Example 1: Backend Implementation Task

```typescript
const task: Task = {
  id: 'task-005',
  title: 'Implement CRUD endpoints',
  description: 'Create REST API endpoints for todo operations',
  type: 'implementation',
  component: 'backend',
  priority: 'critical',
  complexity: 'complex',
  estimated_hours: 8,
  dependencies: ['task-004'],
  acceptance_criteria: [
    'All CRUD endpoints implemented',
    'Request/response validation working',
    'Error handling in place',
    'Tests passing'
  ],
  skills_required: ['fastapi', 'rest-api'],
  files_to_modify: [
    'backend/routers/todos.py',
    'backend/schemas/todo.py',
    'backend/services/todo_service.py'
  ],
  validation_steps: [
    'Run pytest',
    'Test all endpoints with curl',
    'Verify error responses',
    'Check API documentation'
  ]
};

const context: PromptContext = {
  feature_name: 'Todo Management',
  spec_path: 'specs/todo-management/spec.md',
  plan_path: 'specs/todo-management/plan.md',
  infrastructure_path: 'specs/todo-management/infrastructure.yaml',
  related_files: [
    { path: 'backend/models/todo.py', description: 'Todo data model' },
    { path: 'backend/database.py', description: 'Database connection' }
  ],
  constraints: [
    'Must use JWT authentication',
    'Must implement user isolation',
    'Response time < 200ms'
  ],
  security_requirements: [
    'Validate all user input',
    'Implement rate limiting',
    'Never expose user IDs in URLs'
  ],
  performance_requirements: [
    'Use database indexes',
    'Implement pagination',
    'Cache frequently accessed data'
  ]
};

const generator = new ClaudeCodePromptGenerator();
const prompt = generator.generateExecutablePrompt(task, context);

console.log(prompt);
```

### Example 2: Testing Task

```typescript
const testingTask: Task = {
  id: 'task-008',
  title: 'Write backend unit tests',
  description: 'Create unit tests for all backend services',
  type: 'testing',
  component: 'backend',
  priority: 'high',
  complexity: 'moderate',
  estimated_hours: 6,
  dependencies: ['task-005'],
  acceptance_criteria: [
    'All services have unit tests',
    'Code coverage > 80%',
    'All tests passing',
    'Edge cases covered'
  ],
  skills_required: ['pytest', 'testing'],
  files_to_modify: [
    'backend/tests/test_todo_service.py',
    'backend/tests/test_api.py'
  ],
  validation_steps: [
    'Run pytest with coverage',
    'Check coverage report',
    'Verify all tests pass',
    'Review test quality'
  ]
};

const testPrompt = generator.generateExecutablePrompt(testingTask, context);
```

## Prompt Quality Guidelines

```yaml
quality_guidelines:
  clarity:
    - "Use clear, unambiguous language"
    - "Define all technical terms"
    - "Provide examples where helpful"
    - "Structure information logically"

  completeness:
    - "Include all necessary context"
    - "Specify all requirements"
    - "Define success criteria"
    - "Provide validation steps"

  actionability:
    - "Make instructions executable"
    - "Provide specific commands"
    - "Define clear next steps"
    - "Remove ambiguity"

  context:
    - "Reference relevant documents"
    - "Link to related tasks"
    - "Explain dependencies"
    - "Provide background information"
```

## No-Manual-Coding Enforcement

```yaml
enforcement_rules:
  prompt_requirements:
    - "Every task must have an executable prompt"
    - "Prompts must be self-contained"
    - "All context must be provided"
    - "Validation must be automated"

  human_role:
    - "Review generated prompts"
    - "Approve execution"
    - "Validate results"
    - "Provide feedback"

  ai_role:
    - "Execute prompts autonomously"
    - "Generate code"
    - "Run tests"
    - "Validate outputs"

  prohibited_actions:
    - "Manual code writing"
    - "Direct file editing"
    - "Skipping validation"
    - "Bypassing prompts"
```

## Validation Prompt Template

```markdown
# Validation: {{TASK_TITLE}}

## Task ID
{{TASK_ID}}

## Validation Checklist

### Acceptance Criteria
{{#each ACCEPTANCE_CRITERIA}}
- [ ] {{this}}
{{/each}}

### Validation Steps
{{#each VALIDATION_STEPS}}
{{@index}}. {{this}}
{{/each}}

## Verification Commands

```bash
{{#each VERIFICATION_COMMANDS}}
# {{this.description}}
{{this.command}}
{{this.expected_output}}

{{/each}}
```

## Success Criteria

All of the following must be true:
{{#each SUCCESS_CRITERIA}}
- {{this}}
{{/each}}

## If Validation Fails

1. Review the error messages
2. Check the implementation against requirements
3. Fix the issues
4. Re-run validation
5. Do not proceed until all criteria pass

## Rollback Procedure

If validation fails and cannot be fixed:
1. Revert changes: `git reset --hard HEAD`
2. Review the prompt for clarity
3. Refine the approach
4. Re-execute the task
```

## Integration Points

- **Depends On**: `task-breakdown-engine` (task definitions)
- **Next Skill**: None (final skill in chain)
- **Outputs To**: Claude Code execution, CI/CD pipelines

## Performance Targets

- Prompt generation: < 2 seconds
- Validation prompt: < 1 second
- Prompt quality score: > 90%

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
