# Roblox Sky Island Jump

Rojo ではゲームロジックだけを管理します。
地形、足場、コイン、Hazard の配置は Roblox Studio 側で管理してください。

## Studio 側で必要な配置

```text
Workspace
  World
    Coins
      Coin などの BasePart
    Hazards
      Hazard などの BasePart
```

Hazard は Studio 側で次のように設定してください。

- `Transparency = 1`
- `CanCollide = false`
- `Anchored = true`

## JumpPower について

このゲームではサーバー側で `Humanoid.JumpPower` を変更します。
必要に応じて Roblox Studio 側で `StarterPlayer.CharacterUseJumpPower` を有効にしてください。

## Rojo 管理対象

- `ServerStorage`
  - `PlayerData`
  - `Leaderboard`
  - `JumpConfig`
- `ServerScriptService`
  - `CoinService`
  - `HazardService`
  - `PlayerLifecycleService`
  - `FinishService`
  - `BackgroundMusicService`
- `StarterPlayerScripts`
  - `SprintController`

RemoteFunction は使っていません。
タブレットなどのタッチ操作では、ジャンプボタンの横に走るボタンが出ます。

## 追加演出

- コインはサーバー側で回転します。
- コイン取得時に効果音が鳴ります。
- Jump が上がったとき、プレイヤーが短時間光ります。
- Level7 の頂上にいる間、一定時間ごとに花火と歓声が出ます。
- BGM は `SoundService` でループ再生します。

Level7 の頂上判定には、Studio 側の次の Model または Part を使います。

- `Workspace.World.Blockout_Parts.Level_7`
- `Workspace.World.Blockout_Parts.Level_7_Goal`

音を変えたい場合は `src/ServerStorage/JumpConfig.lua` の `COIN_SOUND_ID` や `BACKGROUND_MUSIC_SOUND_ID` などを書き換えてください。

## Level7 のチェックポイント

うまく判定しない場合は、Studio 側で透明のチェックポイント Part を置くのがおすすめです。

- `Workspace.World.Blockout_Parts.Level_7_Goal`

設定例:

- `Anchored = true`
- `CanCollide = false`
- `Transparency = 1`
- 円柱の上面より少し上に置く
- プレイヤーが上に乗った時だけ触れるくらいの薄い板にする
