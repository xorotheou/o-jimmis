# Jimmis Vertical Slice

## Objective

Phase 5 turns the reusable adventure engine into a first playable Jimmis slice with a real quest chain, save/load support, and developer inspection tools.

## Launch

Run the slice from:

```text
res://content/jimmis/bootstrap/jimmis_bootstrap.tscn
```

The bootstrap registers authored content, creates the player rig, shows the prototype HUD, and can start a new game or continue from the last save.

## Locations

- `village_square`
- `cafe`
- `church_exterior`
- `church_interior`
- `main_street`

## NPCs

- `cafe_owner`
- `nicola`
- `theo`
- `priest`
- `villager`

The slice demonstrates major, named-local, and background NPC tiers with relationship and memory state.

## Quest and Puzzle

- Quest: `vertical_slice_church_problem`
- Puzzle: `church_wiring_puzzle`

The intended path is:

1. Talk to the café owner.
2. Learn about Nicola and Theo.
3. Collect the repair items.
4. Combine the parts into a repaired fuse.
5. Repair the church panel.
6. Receive the church key from Nicola.
7. Enter the church.
8. Find the storeroom clue.
9. Complete the quest.

## Inventory

The slice includes:

- `old_wire`
- `electrical_fuse`
- `pliers`
- `screwdriver`
- `cafe_receipt`
- `broken_hook`
- `rope`
- `repaired_fuse`
- `retrieval_hook`
- `church_key`

## Developer Tools

The prototype HUD exposes:

- location / spawn / camera / time
- inventory
- quest objective state
- story flags
- NPC relationships
- recent run summaries
- save/load, teleport, give-item, flag, puzzle, and time controls

## Validation

Run:

```bash
python3 scripts/validate_project.py
python3 -m unittest discover -s tests -v
godot --headless --path /home/td/jimmis res://tests/smoke_phase5_full_vertical_slice_test.tscn
```

The branch also includes content, inventory, dialogue, save/load, and full-flow smoke scenes for the slice.

## Known Limitations

- The art is placeholder geometry.
- The UI is prototype-quality.
- Headless smoke tests may emit renderer-side mesh warnings in this environment, but the tests complete successfully.

