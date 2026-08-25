#!/usr/bin/env python3
"""Static contract tests runnable without a Godot binary."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class FoundationContractTests(unittest.TestCase):
    def read(self, path: str) -> str:
        return (ROOT / path).read_text()

    def test_bootstrap_registers_core_services(self) -> None:
        source = self.read("engine/core/bootstrap.gd")
        for service in ("events", "state", "config", "logger"):
            self.assertIn(f'register_service("{service}"', source)
        self.assertIn("GameEvents.engine_ready.emit()", source)

    def test_state_publishes_changes_and_snapshots(self) -> None:
        source = self.read("engine/core/game_state.gd")
        self.assertIn("GameEvents.state_changed.emit(key, value)", source)
        self.assertIn("duplicate(true)", source)

    def test_world_runtime_has_required_navigation_boundaries(self) -> None:
        world = self.read("engine/world/world_manager.gd")
        player = self.read("engine/world/player_controller.gd")
        self.assertIn("unload_current_location()", world)
        self.assertIn("_spawn_player(resolved_spawn)", world)
        self.assertIn("_location_definitions", world)
        self.assertIn("has_location_definition", world)
        self.assertNotIn("GameState.set_value(&\"world/location_definitions", world)
        self.assertIn("NavigationAgent3D", player)
        self.assertIn("destination_reached", player)
        self.assertIn("destination_unreachable.emit", player)

    def test_internal_world_fixture_has_two_spawns_and_camera_zones(self) -> None:
        fixture = self.read("content/test_environment/world_test.tscn")
        self.assertIn("spawn_id = &\"area_a\"", fixture)
        self.assertIn("spawn_id = &\"area_b\"", fixture)
        self.assertIn("CameraZoneA", fixture)
        self.assertIn("CameraZoneB", fixture)

    def test_adventure_actions_remain_deterministic_and_restricted(self) -> None:
        actions = self.read("engine/adventure/action_executor.gd")
        self.assertIn('&"set_flag"', actions)
        self.assertIn('&"add_item"', actions)
        self.assertIn('Unknown deterministic action', actions)
        self.assertNotIn("HTTP", actions)

    def test_adventure_services_cover_the_core_gameplay_loop(self) -> None:
        inventory = self.read("engine/adventure/inventory.gd")
        dialogue = self.read("engine/adventure/dialogue_service.gd")
        puzzles = self.read("engine/adventure/puzzle_service.gd")
        self.assertIn("func combine", inventory)
        self.assertIn("func choose", dialogue)
        self.assertIn("func complete", puzzles)
        self.assertIn("completion_actions", puzzles)

    def test_advanced_state_is_deterministic_and_ai_is_non_authoritative(self) -> None:
        save = self.read("engine/save/save_service.gd")
        npc = self.read("engine/npc/npc_service.gd")
        conversation = self.read("engine/ai/npc_conversation_service.gd")
        self.assertIn("CURRENT_VERSION", save)
        self.assertIn('"puzzles": Puzzles.snapshot()', save)
        self.assertIn("World.load_location(location_id)", save)
        self.assertIn("World.has_location_definition(location_id)", save)
        self.assertIn("return FAILED", save)
        self.assertNotIn("Story._flags =", save)
        self.assertIn("Unsupported save version", save)
        self.assertIn("clampi", npc)
        self.assertIn("fallback_line", conversation)
        self.assertNotIn("AdventureActionExecutor.execute", conversation)

    def test_quests_complete_only_through_deterministic_actions(self) -> None:
        quests = self.read("engine/adventure/quest_service.gd")
        self.assertIn("_all_objectives_complete", quests)
        self.assertIn("AdventureActionExecutor.execute", quests)
        actions = self.read("engine/adventure/action_executor.gd")
        self.assertIn("Story.restore(story_snapshot)", actions)
        self.assertIn("Inventory.restore(inventory_snapshot)", actions)
        inventory = self.read("engine/adventure/inventory.gd")
        self.assertIn("can_add_item", inventory)
        self.assertIn("restore(snapshot)", inventory)

    def test_content_is_separate_from_engine(self) -> None:
        self.assertTrue((ROOT / "content").is_dir())
        self.assertTrue((ROOT / "engine").is_dir())
        self.assertNotIn("content/", self.read("engine/core/bootstrap.gd"))

if __name__ == "__main__":
    unittest.main(verbosity=2)
