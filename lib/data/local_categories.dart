import '../models/category_model.dart';

class LocalCategories {
  static const List<GameCategory> categories = [
    GameCategory(
      id: '1',
      name: 'Lugares',
      icon: '🌍',
      words: [
        'Playa',
        'Hospital',
        'Escuela',
        'Banco',
        'Restaurante',
        'Cine',
        'Circo',
        'Supermercado',
        'Aeropuerto',
        'Estación de Policía',
      ],
    ),
    GameCategory(
      id: '2',
      name: 'Comida Latina',
      icon: '🌮',
      words: [
        'Arepa',
        'Tacos',
        'Empanada',
        'Ceviche',
        'Tamales',
        'Feijoada',
        'Asado',
        'Paella',
        'Burrito',
        'Sancocho',
      ],
    ),
    GameCategory(
      id: '3',
      name: 'Tecnología',
      icon: '💻',
      words: [
        'Python',
        'Servidor',
        '404 Not Found',
        'Mouse',
        'Teclado',
        'Monitor',
        'WiFi',
        'Smartphone',
        'Robot',
        'Inteligencia Artificial',
      ],
    ),
  ];
}
