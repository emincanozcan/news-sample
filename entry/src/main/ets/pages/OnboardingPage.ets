import { NewsTopic } from '../models/NewsModels';
import { NewsRepository } from '../services/NewsRepository';
import { AppSettingsStore } from '../store/AppSettingsStore';
import { PreferenceKeys } from '../services/PreferencesService';
import { common } from '@kit.AbilityKit';

@Component
export struct OnboardingPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State topics: NewsTopic[] = NewsRepository.getTopics();
  @State selectedTopicIds: string[] = ['top', 'sports'];
  @State briefingHour: number = 8;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          Text($r('app.string.onboarding_title'))
            .fontColor($r('app.color.textPrimary'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%')
          Text($r('app.string.onboarding_subtitle'))
            .fontColor($r('app.color.textSecondary'))
            .fontSize(12)
            .textAlign(TextAlign.Center)

          Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
            ForEach(this.topics, (topic: NewsTopic) => {
              SelectableChip({
                label: topic.title,
                selected: this.selectedTopicIds.includes(topic.id),
                onTap: () => {
                  this.toggleTopic(topic.id);
                }
              })
            }, (topic: NewsTopic) => topic.id)
          }
          .width('100%')

          Text($r('app.string.onboarding_briefing_title'))
            .fontColor($r('app.color.textPrimary'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          Row({ space: 8 }) {
            Button($r('app.string.onboarding_briefing_morning'))
              .layoutWeight(1)
              .height(30)
              .fontSize(11)
              .fontColor(this.briefingHour === 8 ? $r('app.color.bgColor') : $r('app.color.textPrimary'))
              .backgroundColor(this.briefingHour === 8 ? $r('app.color.stateSuccess') : $r('app.color.surfaceChip'))
              .borderRadius(14)
              .onClick(() => {
                this.briefingHour = 8;
              })
            Button($r('app.string.onboarding_briefing_evening'))
              .layoutWeight(1)
              .height(30)
              .fontSize(11)
              .fontColor(this.briefingHour === 19 ? $r('app.color.bgColor') : $r('app.color.textPrimary'))
              .backgroundColor(this.briefingHour === 19 ? $r('app.color.stateSuccess') : $r('app.color.surfaceChip'))
              .borderRadius(14)
              .onClick(() => {
                this.briefingHour = 19;
              })
          }
          .width('100%')

          Button($r('app.string.onboarding_continue'))
            .fontSize(13)
            .fontColor($r('app.color.textPrimary'))
            .backgroundColor($r('app.color.backgroundColor'))
            .width('100%')
            .height(34)
            .borderRadius(17)
            .onClick(() => {
              this.finishOnboarding();
            })

          Button($r('app.string.onboarding_skip'))
            .fontSize(12)
            .fontColor($r('app.color.textSecondary'))
            .backgroundColor($r('app.color.surfaceCard'))
            .width('100%')
            .height(34)
            .borderRadius(17)
            .onClick(() => {
              this.skipOnboarding();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 18, bottom: 18 })
      }
      .scrollBar(BarState.Off)
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      this.selectedTopicIds = AppSettingsStore.getPreferredTopicIds();
      const reminderHour = AppStorage.get(PreferenceKeys.reminderHour) as number | undefined;
      this.briefingHour = reminderHour === 19 ? 19 : 8;
    })
    .backgroundColor($r('app.color.bgColor'))
    .hideBackButton(true)
  }

  private toggleTopic(topicId: string): void {
    if (this.selectedTopicIds.includes(topicId)) {
      if (this.selectedTopicIds.length === 1) {
        return;
      }
      this.selectedTopicIds = this.selectedTopicIds.filter((id: string) => id !== topicId);
      return;
    }
    this.selectedTopicIds = [...this.selectedTopicIds, topicId];
  }

  private finishOnboarding(): void {
    AppSettingsStore.setPreferredTopicIds(this.selectedTopicIds).then(() => {
      return AppSettingsStore.setReminderEnabled(true);
    }).then(() => {
      return AppSettingsStore.setReminderHour(this.briefingHour);
    }).then(() => {
      return AppSettingsStore.setOnboardingDone(true);
    }).finally(() => {
      this.pageStack.pop();
    });
  }

  private skipOnboarding(): void {
    AppSettingsStore.setOnboardingDone(true).finally(() => {
      this.pageStack.pop();
    });
  }
}

@Component
struct SelectableChip {
  @Prop label: string;
  @Prop selected: boolean = false;
  onTap?: () => void;

  build() {
    Text(this.label)
      .fontColor(this.selected ? $r('app.color.bgColor') : $r('app.color.textPrimary'))
      .fontSize(12)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.selected ? $r('app.color.stateSuccess') : $r('app.color.surfaceChip'))
      .borderRadius(14)
      .margin({ right: 6, bottom: 6 })
      .onClick(() => {
        if (this.onTap) {
          this.onTap();
        }
      })
      .accessibilityText(`${this.getString($r('app.string.a11y_topic_chip'))}: ${this.label}`)
  }

  private getString(resource: ResourceStr): string {
    if (typeof resource === 'string') {
      return resource;
    }
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      return context.resourceManager.getStringSync(resource.id);
    } catch (_error) {
      return '';
    }
  }
}
