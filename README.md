# colbss-policebag

Inspired by: https://github.com/inferno-collection/Police-Panic

## Setup

1. Add the following to `/resources/[qb]/qb-core/shared/items.lua`:

```
['panicbutton']                   = {['name'] = 'panicbutton',                ['label'] = 'Panic Button',   ['weight'] = 1000,         ['type'] = 'item',         ['image'] = 'panic.png',               ['unique'] = true,          ['useable'] = true,      ['shouldClose'] = true,      ['combinable'] = nil,   ['description'] = 'A police panic button.'},
```

2. Add `panic.png` into `[qb]/qb-inventory/html/images`

Optional:

3. Add custom sounds to `resources/[standalone]/interact-sound/client/html/sounds` and update the sound names in the config

## Usage

Use the `Panic Button` item or use `/panicb`
