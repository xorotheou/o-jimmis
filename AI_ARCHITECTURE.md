# AI Architecture

AI is presentation-only. Deterministic systems build an NPC context from profile, authorized knowledge, relationship, compact memory, and current world state. A future adapter may turn that context into wording, but it cannot execute actions or mutate game services.

`NpcConversation.respond()` currently provides cached fallback dialogue. It is intentionally playable with AI disabled or unavailable. Any future asynchronous provider must apply request/context limits and pass output through validation before display; only authored deterministic consequences may change gameplay.
