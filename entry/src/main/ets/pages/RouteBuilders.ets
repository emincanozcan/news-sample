import { ArticleDetailPage } from './ArticleDetailPage';
import { BriefingPage } from './BriefingPage';
import { HeadlineFlow } from './HeadlineFlow';
import { HistoryPage } from './HistoryPage';
import { HomePage } from './HomePage';
import { OnboardingPage } from './OnboardingPage';
import { SavedPage } from './SavedPage';
import { SettingsPage } from './SettingsPage';

@Builder
export function HomePageBuilder() {
  HomePage();
}

@Builder
export function HeadlineFlowBuilder() {
  HeadlineFlow();
}

@Builder
export function OnboardingPageBuilder() {
  OnboardingPage();
}

@Builder
export function ArticleDetailPageBuilder() {
  ArticleDetailPage();
}

@Builder
export function SavedPageBuilder() {
  SavedPage();
}

@Builder
export function HistoryPageBuilder() {
  HistoryPage();
}

@Builder
export function BriefingPageBuilder() {
  BriefingPage();
}

@Builder
export function SettingsPageBuilder() {
  SettingsPage();
}
