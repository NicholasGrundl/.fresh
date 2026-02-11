Give your agents dedicated jobs
You wouldn’t ask a new hire to simultaneously check visual consistency across code updates, evaluate the system’s fundamental structure, and hunt for bugs. That’s three different jobs requiring three different mindsets. The same is true for AI.

As Codex churned out more code, human code review became the bottleneck—there was simply too much for the team to look at carefully. Marsan’s solution was to create specialized AI reviewers that could do a first pass, flagging issues so humans could focus their attention where it mattered.

He set up three separate Codex sessions, each with a single focus:

Compose police: Checks for user interface issues—making sure the app’s visual elements follow consistent patterns.
Tech lead: Looks for architectural problems—flagging duplicate code or structural decisions that could cause trouble later.
Bug hunter: Searches for potential bugs—logic errors, edge cases, anything that might break.
Giving each agent a specific role made them all better at their jobs. The three don’t coordinate, so sometimes all three flag the same line of code. “You know you’ve done something wrong when compose police, tech lead, and bug hunter all comment on the same line.”

The same principle applies to what information you let Codex see. When the team builds the app, the system spits out thousands of lines of status updates, most of it routine. Marsan configured his setup to filter the routine notifications out and only surface failures. Codex performed dramatically better.

Embiricos pointed out that these fixes help human developers, too. When you show someone 70,000 lines of code, their eyes glaze over—they skim and miss details. The same happens to AI. If you are intentional about what information you give the agent, it will focus better and produce better outputs. The less junk Codex has to sift through, the more it catches what counts.

One practical tip: When Codex submits comments on code reviews, it needs to label those comments as coming from AI. Otherwise, the comments show up under your name, so it looks like you’re critiquing your own code. “It’ll just be RJ commenting on RJ,” Marsan said, “and you look a little bit like you’re going crazy.”