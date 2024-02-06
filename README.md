# colbss-policebag

# WORK IN PROGRESS

## Setup

1. Add the following to `/resources/[qb]/qb-core/shared/items.lua`:

```
['panicbutton']                   = {['name'] = 'panicbutton',                ['label'] = 'Panic Button',   ['weight'] = 1000,         ['type'] = 'item',         ['image'] = 'panic.png',               ['unique'] = true,          ['useable'] = true,      ['shouldClose'] = true,      ['combinable'] = nil,   ['description'] = 'A police panic button.'},

```

2. Add `panic.png` into `[qb]/qb-inventory/html/images`
