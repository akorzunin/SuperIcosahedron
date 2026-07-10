The idea is already good: modifiers could be made not just bonuses, but a "risk/reward" system, where the player decides how much to break a session for points.

## 1. General idea of ​​the mod system

Modifiers can be divided into:

1. **Base mod** - determines what changes.
2. **Sign** - good, bad, or strange.
3. **Tier** - effect strength.
4. **Quality** - rarity/additional property.
5. **Mutations** - special distortions that can be superimposed.

Example:

> Rare green tier 4 mod:
> `+35% score multiplier, but +10% node spawn speed`

Or:

> Legendary purple tier 6 mod:
> `x3 multiplier for 10 seconds, but the route to the next node is randomized and you can't pick up other mods`

---

# 2. What can be added to your mods

## Time Slowdown

Current idea:

- decreases the score multiplier;
- a cell/node spawns, which you must reach via a specific path;
- if reached, plus points;
- if not, minus points;
- you can't pick up other mods.

Can be enhanced:

### Variations

- **Time Contract**
Time slows down, a route appears. You must follow it strictly along the nodes.
- Success: large bonus to points/multiplier.
- Error: Loss of multiplier or points.
- Other mods cannot be picked up.

- **Fragile Route**
If the player deviates from the path, the route disappears and they receive a penalty.

- **Combo Route**
The faster the route is completed, the greater the bonus.

- **Anti-Route**
A dangerous path is shown that cannot be followed. You must reach the goal while avoiding the specified nodes.

---

## Speed ​​Boost

Currently:

- Just +points.

Can be made more interesting:

### Variations

- **Adrenaline**
Higher speed, higher points for nodes.

- **Accelerate**
The longer you avoid crashing, the higher your speed and multiplier.

- **Speed ​​Debt**
Gives points immediately, but temporarily increases your speed and the chance of dangerous spawns.

- **Overload**
Speed ​​increases every N seconds until you pick up the next basic mod.

---

## Spike Spawn

Currently:

- Spike spawns on the sides;
- Picking up spikes minus points.

Can be added:

### Variations

- **Spike Arena**
Dangerous areas appear on the sides.

- **Side Infection** (Corruption)
Spikes slowly spread until a player picks up a cleansing mod.

- **Deceptive Spike ... If the session is limited by time/bits/nodes, you can do the following:

### Options

- **+10 seconds**
- **+1 phase**
- **Timer freeze**
- **Delayed death**
If a player is about to lose, they get an extra 5 seconds, but the multiplier is reduced.
- **Last chance**
If all points are lost, the player remains in the game with 1 point, but receives a strong negative modifier.

---

# 3. Points, multiplier, HP

I wouldn't introduce a separate HP value if the game is arcade-style and fast-paced.

It's better to do it this way:

## Points = health

That is:

- nodes give points;
- collisions with walls/spikes remove points;
- if points drop to 0, the game is lost.

Pros:

- simpler system;
- every decision matters;
- mods with minus points become truly dangerous;
- the player constantly balances between greed and survival.

## Multiplier = Risk

It's better to make the multiplier a separate value:

- increases points earned;
- can be reduced by damage;
- can be lost if an error occurs;
- can be targeted by some mods.

Example:

- per node: `100 * multiplier`;
- hitting a spike: `-200 points and -0.2 multiplier`;
- hitting a solid side: loss or a huge penalty.

---

# 4. Modifier Quality

Quality can affect not only the strength but also the "purity" of the effect.

## Normal

Simple effect.

Examples:

- `+100 points`
- `+0.1 multiplier`
- `+5% speed`

## Rare

Has a primary effect and an additional secondary effect.

Examples:

- `+300 points, but +5% speed`
- `+0.3 multiplier, but 2 spikes appear`
- `+10 seconds, but the next mod will be red`

## Legendary

Significantly changes the rules.

Examples:

- `Points for nodes x3 for 15 seconds`
- `All red mods turn green for 10 seconds`
- `Cannot die for 5 seconds, but after that the multiplier is reset`
- `Each node gives points twice, but spikes spawn`

---

# 5. Modifier Symbols

## Green

Positive effect.

Examples:

- more points;
- Higher multiplier;
- Lower speed;
- Fewer spikes;
- Session extension.

## Red

Negative effect, but may be needed for balance or risk-reward.

Examples:

- Fewer points;
- Lower multiplier;
- Higher speed;
- More spikes;
- Shorter timer.

But red mods can be made useful through synergies.

For example:

> The more red mods active, the higher the final bonus.

## Purple

Special mutations. Not always positive or negative.

Examples:

- Randomly changes the sign of the next mod;
- Doubles the next mod;
- Turns all nodes into dangerous/bonus nodes;
- Changes the rhythm of the music;
- Makes the arena rotate;
- Temporarily hides part of the path;
- Changes controls;
- Applies the mod's effect multiple times.

---

# 6. Tier

Tiers 1 to 7 are good.

You can do it like this:

## Example of strength by tier

### Points

- T1: ±100
- T2: ±250
- T3: ±500
- T4: ±1000
- T5: ±2000
- T6: ±4000
- T7: ±8000

### Multiplier

- T1: ±0.1
- T2: ±0.2
- T3: ±0.35
- T4: ±0.5
- T5: ±0.75
- T6: ±1.0
- T7: ±1.5

### Speed

- T1: ±3%
- T2: ±6%
- T3: ±10%
- T4: ±15%
- T5: ±22%
- T6: ±30%
- T7: ±40%

### Thorns

- T1: 1 Thorn
- T2: 2 Thorns
- T3: 3 Thorns
- T4: 5 Thorns
- T5: 7 Thorns
- T6: 10 Thorns
- T7: 15 Thorns or a special pattern

---

# 7. Modifier Application Mechanics

Your Idea:

> After selecting a base mod, subsequent modifiers are applied to it; the cumulative effect is applied after selecting the next base modifier.

This can be conceptualized as "spell stacking."

## Example

The player selects:

1. Base mod: `Multiplier`
2. Symbol: `Green`
3. Tier: `+3`
4. Quality: `Rare`
5. Purple mutation: `Repeat effect`

Then selects the next base mod, and the collected effect is activated:

> `Rare green T3 multiplier, applied twice`

Result:

> `+0.7 multiplier, but +10% speed`

This is a cool system because the player isn't just selecting random bonuses, but completing a "chain".

---

# 8. What else can we come up with?

## 8.1. Cursed mods

A very strong bonus, but with a condition.

Examples:

- +2 multipliers, but one hit = death
- x5 points, but you can't turn back
- +5000 points, if you don't pick up a single node within 10 seconds, you lose
- all nodes give x2, but the spikes are invisible until you get close

---

## 8.2. Mod Selection

After picking up, you can choose between two effects.

Example:

> Choose:
> - +1000 points
> - +0.5 multiplier, but +2 spikes

This adds strategy.

---

## 8.3. Mod Series

Collecting several mods of the same type grants a set bonus.

Examples:

### Three green ones in a row

> The next green mod is doubled.

### Three red ones in a row

> Receive "Rage": x2 node points for 10 seconds.

### Three purple ones in a row

> Arena mutation occurs.

---

## 8.4. Clean Play Combo

You can reward a player not only for collecting nodes, but also for style.

Examples:

- No collisions for 10 seconds: +0.1 multiplier;
- Complete 5 nodes in a row: x2 combo;
- Avoid a spike at the last moment: perfect dodge;
- Complete a route without deviating: perfect path.

---

## 8.5. Dangerous Bonus Nodes

Nodes that give a lot of points, but come with a risk.

Examples:

- **Golden Node** — a lot of points, disappears quickly. - **Red Node** — Gives points but reduces the multiplier.
- **Black Node** — Gives a big bonus but spawns spikes.
- **Pulsing Node** — Gives a different effect depending on the beat of the music.
- **Mirror Node** — Repeats the last mod.

---

## 8.6. Music Mods

Since you have a "music beat," you can strongly tie the mechanics to the rhythm.

Examples:

- Nodes only appear on the beat;
- Points x2 if you select the node exactly on the beat;
- Spikes are active only on the downbeat;
- Speed ​​changes according to the BPM;
- Purple mod can "break" the beat;
- Legendary mod can enable a "drop," where points increase sharply.

---

## 8.7. Environment Mods

If the game is on an icosahedron/sides, you can change the sides themselves.

Examples:

- **Ice** — sliding along the sides.
- **Magnet** — nodes attract/repel.
- **Fog** — some sides are hidden.
- **Pulsation** — sides temporarily become solid.
- **Gravity** — the player is pulled toward a specific side.
- **Rotation** — the arena slowly rotates.
- **Brittle** — a side disappears after passing through.

---

# 9. Specific Modifier Examples

## Green

- `+500 points`
- `+0.3 multiplier`
- `-10% speed`
- `-2 spikes`
- `+10 seconds`
- `next node grants x3`
- `next red mod is canceled`

## Red

- `-500 points`
- `-0.3 multiplier`
- `+15% speed`
- `+3 spikes`
- `-10 seconds`
- `next node disappears faster`
- `one side becomes dense`

## Purple

- `double next effect`
- `invert effect sign`
- `apply effect 3 times`
- `random tier from 1 to 7`
- `next mod becomes legendary`
- `all nodes swap`
- `route becomes hidden`
- `multiplier jumps from x0.5 to x3`

---

# 10. A good basic formula

You can do it like this:

```text
Points per node = 100 * multiplier * combo * beat bonus
```

Where:

- `multiplier` is the basic progression;
- `combo` is the reward for consistent play;
- `beat bonus` is if the action is performed in rhythm.

Example:

```text
100 * 2.5 * 1.4 * 2 = 700 points
```

---

# 11. How to lose

It's best to have several ways to lose:

1. Points drop to 0.
2. The player crashes into a solid side.
3. The session timer runs out.
4. The player fails a special contract.
5. The player has accumulated too many negative mods.

The last option can be made interesting:

## Overload

The player has a limit on active mods.

For example:

```text
Maximum 7 active distortions.
```

If the limit is exceeded, a "collapse" begins:

- speed increases;
- sides become dangerous;
- the multiplier is huge;
- but an error almost guarantees death.
