import { Pages } from './Pages';
import { AppStorageKeys, PreferenceKeys } from '../services/PreferencesService';

@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  @StorageProp(AppStorageKeys.storageHydrated) @Watch('onStorageHydratedChanged')
  storageHydrated: boolean = false;
  @State hasInitializedRootRoute: boolean = false;

  build() {
    Navigation(this.pageStack)
      .mode(NavigationMode.Stack)
      .hideNavBar(true)
      .onAppear(() => {
        this.ensureInitialRoute();
      })
  }

  private onStorageHydratedChanged(): void {
    this.ensureInitialRoute();
  }

  private ensureInitialRoute(): void {
    if (this.hasInitializedRootRoute || !this.storageHydrated || this.pageStack.getAllPathName().length > 0) {
      return;
    }
    const onboardingDone = AppStorage.get(PreferenceKeys.onboardingDone) as boolean | undefined;
    this.pageStack.pushPathByName(Pages.HomePage, null);
    if (!onboardingDone) {
      this.pageStack.pushPathByName(Pages.OnboardingPage, null);
    }
    this.hasInitializedRootRoute = true;
  }
}
