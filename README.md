This project is forked from [nalexn/clean-architecture-swiftui](https://github.com/nalexn/clean-architecture-swiftui)

**WIP**
基本的なアイデアは元のnalexnを利用しているが、SwiftUIの学習も兼ねて一から実装し直した。


### ルール
- ViewはInteractorとDB Modelにのみ依存する。DB Modelは参照するのみで更新はInteractorを通して行う。
- Interactorは、Model層の全てにアクセス可能。ただし複雑な処理はDomain Serviceに依存する。
  - 全てをDomain Serviceで提供することも考えたが、余分な抽象化は避ける。
  - Interactorは、MainActor内で動作する。
- Viewの表示、更新はObservableを通して行う。
  - 他のView、Backgroundでの更新を反映させるために、Property Wrapperを提供する。
