@Component
export struct StatePanel {
  @Prop title: ResourceStr;
  @Prop subtitle: ResourceStr;

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontColor($r('app.color.textPrimary'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
      Text(this.subtitle)
        .fontColor($r('app.color.textSecondary'))
        .fontSize(12)
        .textAlign(TextAlign.Center)
        .maxLines(3)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor($r('app.color.surfaceCard'))
    .borderRadius(18)
    .alignItems(HorizontalAlign.Center)
  }
}
