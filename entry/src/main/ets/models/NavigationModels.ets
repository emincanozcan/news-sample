import { Pages } from '../pages/Pages';

export interface CategoryFeedNavParam {
  topicId: string;
  topicTitle: string;
}

export interface ArticleDetailNavParam {
  articleId: string;
  fromTopicId: string;
}

export interface LibraryNavParam {
  filter: 'all' | 'today' | 'week';
}

export interface OnboardingNavParam {
  completed: boolean;
}

export interface BriefingNavParam {
  source: 'home' | 'notification' | 'settings';
}

export class AppNav {
  static toHome(pageStack: NavPathStack): void {
    pageStack.pushPathByName(Pages.HomePage, null);
  }

  static toHeadlineFlow(pageStack: NavPathStack, param: CategoryFeedNavParam): void {
    pageStack.pushPathByName(Pages.HeadlineFlow, param);
  }

  static toArticleDetail(pageStack: NavPathStack, param: ArticleDetailNavParam): void {
    pageStack.pushPathByName(Pages.ArticleDetailPage, param);
  }

  static toSaved(pageStack: NavPathStack, param: LibraryNavParam): void {
    pageStack.pushPathByName(Pages.SavedPage, param);
  }

  static toHistory(pageStack: NavPathStack, param: LibraryNavParam): void {
    pageStack.pushPathByName(Pages.HistoryPage, param);
  }

  static toOnboarding(pageStack: NavPathStack, param: OnboardingNavParam): void {
    pageStack.pushPathByName(Pages.OnboardingPage, param);
  }

  static toBriefing(pageStack: NavPathStack, param: BriefingNavParam): void {
    pageStack.pushPathByName(Pages.BriefingPage, param);
  }

  static toSettings(pageStack: NavPathStack): void {
    pageStack.pushPathByName(Pages.SettingsPage, null);
  }
}
