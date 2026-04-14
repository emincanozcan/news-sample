import { ArticleDetail, NewsTopic } from '../../models/NewsModels';

export const SEEDED_TOPICS: NewsTopic[] = [
  { id: 'top', title: 'Top News', description: 'Important updates at a glance', accentColor: '#5CC8FF' },
  { id: 'sports', title: 'Sports', description: 'Scores, highlights, and athlete updates', accentColor: '#76E39C' },
  { id: 'economy', title: 'Economics', description: 'Markets and business signals', accentColor: '#F5BC55' },
  { id: 'sky', title: 'Sky News', description: 'Science, weather, and space stories', accentColor: '#B894FF' }
];

export const SEEDED_ARTICLES: ArticleDetail[] = [
  {
    id: 'top-001',
    topicId: 'top',
    title: 'HarmonyOS Next Reaches New Daily Usage Milestone',
    imageUrl: $r('app.media.image1'),
    source: 'HMS Daily',
    publishedAt: '09:19',
    readMinutes: 3,
    isBreaking: true,
    tags: ['HarmonyOS', 'Milestone'],
    heroNote: 'Developers report stronger device consistency across watch experiences.',
    summaryBullets: ['Daily active usage rose week-over-week.', 'Wearable engagement led the growth curve.', 'Developers cited faster update adoption.']
  },
  {
    id: 'top-002',
    topicId: 'top',
    title: 'Watch App Performance Benchmarks Improve in Latest Build',
    imageUrl: $r('app.media.image2'),
    source: 'ArkUI Review',
    publishedAt: '08:45',
    readMinutes: 4,
    isBreaking: false,
    tags: ['Benchmark', 'ArkTS'],
    heroNote: 'Frame pacing remained stable in scrolling-heavy test feeds.',
    summaryBullets: ['Cold start time dropped on test devices.', 'Memory spikes were reduced in card lists.', 'Improvement was strongest in dark-mode lists.']
  },
  {
    id: 'sports-001',
    topicId: 'sports',
    title: 'National Cycling Team Confirms New Training Block',
    imageUrl: $r('app.media.image3'),
    source: 'Sports Pulse',
    publishedAt: '07:55',
    readMinutes: 2,
    isBreaking: false,
    tags: ['Cycling', 'Training'],
    heroNote: 'Coaches are shifting focus to sprint power and recovery metrics.',
    summaryBullets: ['The next race window starts in two weeks.', 'Wearable telemetry is used for pacing decisions.', 'Recovery intervals were extended after recent tests.']
  },
  {
    id: 'sports-002',
    topicId: 'sports',
    title: 'Late Goal Sends Tigers to Cup Semi-Final',
    imageUrl: $r('app.media.image1'),
    source: 'Match Center',
    publishedAt: '07:10',
    readMinutes: 3,
    isBreaking: true,
    tags: ['Football', 'Cup'],
    heroNote: 'A stoppage-time finish completed a second-half comeback.',
    summaryBullets: ['Possession shifted after halftime substitutions.', 'A corner sequence created the winning chance.', 'Defensive pressure remained high through stoppage time.']
  },
  {
    id: 'economy-001',
    topicId: 'economy',
    title: 'Regional Tech Hiring Ticks Up for Third Straight Month',
    imageUrl: $r('app.media.image2'),
    source: 'Market Brief',
    publishedAt: '06:48',
    readMinutes: 4,
    isBreaking: false,
    tags: ['Jobs', 'Tech'],
    heroNote: 'Recruiters cited demand for embedded and wearable engineering skills.',
    summaryBullets: ['Small teams posted more senior roles.', 'Contract openings rose faster than full-time listings.', 'Compensation bands remained stable.']
  },
  {
    id: 'sky-001',
    topicId: 'sky',
    title: 'Meteor Watch Window Opens Tonight Across Northern Region',
    imageUrl: $r('app.media.image3'),
    source: 'Skyline Lab',
    publishedAt: '06:22',
    readMinutes: 2,
    isBreaking: false,
    tags: ['Meteor', 'Night Sky'],
    heroNote: 'Observers are advised to check local cloud and light conditions.',
    summaryBullets: ['Peak visibility is expected after midnight.', 'Urban viewing can improve with darker areas.', 'A short clear period can still offer sightings.']
  }
];
