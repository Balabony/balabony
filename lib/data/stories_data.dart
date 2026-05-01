import '../models/story.dart';

// Metadata only — full text lives server-side in api/get-story.js
const List<Story> allStories = [
  Story(
    id: 'kolobok',
    title: 'Колобок',
    description: 'Улюблена казка про хитрого колобка',
    duration: '2 хв',
    isPremium: false,
  ),
  Story(
    id: 'rukavychka',
    title: 'Рукавичка',
    description: 'Як лісові звірі знайшли собі домівку',
    duration: '3 хв',
    isPremium: false,
  ),
  Story(
    id: 'ripka',
    title: 'Ріпка',
    description: 'Про велику ріпку і дружню родину',
    duration: '2 хв',
    isPremium: false,
  ),
  Story(
    id: 'lysytsia_zhuravei',
    title: 'Лисиця і Журавель',
    description: 'Казка про дружбу та справедливість',
    duration: '4 хв',
    isPremium: true,
  ),
  Story(
    id: 'vovk_kozenata',
    title: 'Вовк і семеро козенят',
    description: 'Як мама-коза врятувала своїх діток',
    duration: '5 хв',
    isPremium: true,
  ),
  Story(
    id: 'solomianyi_bychok',
    title: 'Солом\'яний бичок',
    description: 'Як дід зловив усіх хитрих звірів',
    duration: '4 хв',
    isPremium: true,
  ),
  Story(
    id: 'kotyk_pivnyk',
    title: 'Котик та Півник',
    description: 'Про вірну дружбу і хитру лисицю',
    duration: '4 хв',
    isPremium: true,
  ),
  Story(
    id: 'kotygoroshko',
    title: 'Котигорошко',
    description: 'Богатир із горошини рятує сестру',
    duration: '6 хв',
    isPremium: true,
  ),
];
