import '../models/recipe_model.dart';

final List<RecipeModel> recipes = [
  const RecipeModel(
    title: "Batido de fresa y plátano",
    image: "https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=800",
    time: "10 min",
    difficulty: "Fácil",
    description:
        "Licúa las fresas, el banano y la leche hasta obtener una mezcla cremosa. Puedes agregar hielo para servirlo bien frío.",
    ingredients: [
      "Fresas",
      "Banano",
      "Leche",
    ],
  ),

  const RecipeModel(
    title: "Ensalada de frutas",
    image: "https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=800",
    time: "15 min",
    difficulty: "Fácil",
    description:
        "Lava todas las frutas, córtalas en trozos pequeños y mézclalas. Puedes añadir yogur o miel si lo deseas.",
    ingredients: [
      "Manzana",
      "Banano",
      "Fresas",
      "Uvas",
    ],
  ),

  const RecipeModel(
    title: "Muffins de arándanos",
    image: "https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=800",
    time: "25 min",
    difficulty: "Media",
    description:
        "Mezcla los ingredientes, incorpora los arándanos y hornea hasta que los muffins estén dorados.",
    ingredients: [
      "Arándanos",
      "Harina",
      "Leche",
      "Huevos",
    ],
  ),

  const RecipeModel(
    title: "Pollo al horno",
    image: "https://images.unsplash.com/photo-1518492104633-130d0cc84637?w=800",
    time: "45 min",
    difficulty: "Media",
    description:
        "Sazona el pollo, añade las papas y el tomate. Hornea hasta que el pollo esté completamente cocido y dorado.",
    ingredients: [
      "Pollo",
      "Papa",
      "Tomate",
    ],
  ),

  const RecipeModel(
    title: "Omelette",
    image: "https://images.unsplash.com/photo-1510693206972-df098062cb71?w=800",
    time: "12 min",
    difficulty: "Fácil",
    description:
        "Bate los huevos, vierte la mezcla en una sartén caliente y agrega queso y tomate antes de doblar el omelette.",
    ingredients: [
      "Huevos",
      "Queso",
      "Tomate",
    ],
  ),
];  