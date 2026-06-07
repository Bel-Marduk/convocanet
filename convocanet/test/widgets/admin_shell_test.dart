import 'package:flutter_test/flutter_test.dart';
import 'package:convocanet/widgets/admin_shell.dart';

void main() {
  group('AdminShell.computeSelectedIndex', () {
    test('returns 0 for /admin (dashboard)', () {
      expect(AdminShell.computeSelectedIndex('/admin'), 0);
    });

    test('returns 0 for /admin/ when present', () {
      expect(AdminShell.computeSelectedIndex('/admin/'), 0);
    });

    test('returns 1 for /admin/convocatorias', () {
      expect(AdminShell.computeSelectedIndex('/admin/convocatorias'), 1);
    });

    test('returns 2 for /admin/users', () {
      expect(AdminShell.computeSelectedIndex('/admin/users'), 2);
    });

    test('returns 3 for /admin/messages', () {
      expect(AdminShell.computeSelectedIndex('/admin/messages'), 3);
    });

    test('returns 4 for /admin/categories', () {
      expect(AdminShell.computeSelectedIndex('/admin/categories'), 4);
    });

    test('edit screen /admin/convocatorias/:id/edit still highlights Convocatorias (1)', () {
      expect(
        AdminShell.computeSelectedIndex('/admin/convocatorias/abc-123/edit'),
        1,
      );
    });

    test('longest-prefix match wins: /admin/categories not /admin', () {
      expect(AdminShell.computeSelectedIndex('/admin/categories'), 4);
    });
  });

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
