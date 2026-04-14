@Component
export struct StatusBanner {
  @Prop text: ResourceStr | string;
  @Prop tone: 'info' | 'warning' | 'success' = 'info';

  build() {
    if (typeof this.text === 'string') {
      Text(this.text)
        .fontColor($r('app.color.textPrimary'))
        .fontSize(11)
        .width('100%')
        .padding({ left: 10, right: 10, top: 7, bottom: 7 })
        .backgroundColor(this.resolveBackgroundColor())
        .borderRadius(12)
        .textAlign(TextAlign.Center)
    } else {
      Text(this.text)
        .fontColor($r('app.color.textPrimary'))
        .fontSize(11)
        .width('100%')
        .padding({ left: 10, right: 10, top: 7, bottom: 7 })
        .backgroundColor(this.resolveBackgroundColor())
        .borderRadius(12)
        .textAlign(TextAlign.Center)
    }
  }

  private resolveBackgroundColor(): ResourceColor {
    if (this.tone === 'warning') {
      return $r('app.color.statusWarningBg');
    }
    if (this.tone === 'success') {
      return $r('app.color.statusSuccessBg');
    }
    return $r('app.color.statusInfoBg');
  }
}
