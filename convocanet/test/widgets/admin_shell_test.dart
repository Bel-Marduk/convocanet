import 'package:flutter_test/flutter_test.dart';
import 'package:convocanet/widgets/admin_shell.dart';

void main() {
  group('AdminShell.label', () {
    test('returns Spanish label per index', () {
      expect(AdminShell.label('es', 0), 'Dashboard');
      expect(AdminShell.label('es', 1), 'Convocatorias');
      expect(AdminShell.label('es', 2), 'Usuarios');
      expect(AdminShell.label('es', 3), 'Mensajes');
      expect(AdminShell.label('es', 4), 'Categorías');
    });

    test('returns English label per index', () {
      expect(AdminShell.label('en', 0), 'Dashboard');
      expect(AdminShell.label('en', 1), 'Calls');
      expect(AdminShell.label('en', 2), 'Users');
      expect(AdminShell.label('en', 3), 'Messages');
      expect(AdminShell.label('en', 4), 'Categories');
    });
  });
}
