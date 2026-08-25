
## Save and AI

Save state through `Save.save_game(path)` and load through `Save.load_game(path)`; upgrade versions explicitly in `_migrate`. Keep network/model code out of gameplay services and extend `NpcConversation` only as a non-authoritative, asynchronous presentation adapter.
