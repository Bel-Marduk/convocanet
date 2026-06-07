import 'package:flutter_test/flutter_test.dart';
import 'package:convocanet/models/convocatoria.dart';

Convocatoria _makeConvocatoria({required String status, String? id}) {
  return Convocatoria(
    id: id ?? 'test-id',
    titleEs: 'Test ES',
    titleEn: 'Test EN',
    descriptionEs: 'Test description ES',
    descriptionEn: 'Test description EN',
    status: status,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  group('Convocatoria status predicates', () {
    test('isActive is true only for active', () {
      expect(_makeConvocatoria(status: 'active').isActive, isTrue);
      expect(_makeConvocatoria(status: 'expired').isActive, isFalse);
      expect(_makeConvocatoria(status: 'pending').isActive, isFalse);
      expect(_makeConvocatoria(status: 'rejected').isActive, isFalse);
    });

    test('isPending is true only for pending', () {
      expect(_makeConvocatoria(status: 'pending').isPending, isTrue);
      expect(_makeConvocatoria(status: 'active').isPending, isFalse);
    });

    test('isRejected is true only for rejected', () {
      expect(_makeConvocatoria(status: 'rejected').isRejected, isTrue);
      expect(_makeConvocatoria(status: 'active').isRejected, isFalse);
      expect(_makeConvocatoria(status: 'pending').isRejected, isFalse);
      expect(_makeConvocatoria(status: 'expired').isRejected, isFalse);
    });

    test('isExpired is true only for expired', () {
      expect(_makeConvocatoria(status: 'expired').isExpired, isTrue);
      expect(_makeConvocatoria(status: 'active').isExpired, isFalse);
    });

    test('isPermanent is true only for permanent', () {
      expect(_makeConvocatoria(status: 'permanent').isPermanent, isTrue);
      expect(_makeConvocatoria(status: 'active').isPermanent, isFalse);
    });

    test('isOpen is true for active and permanent', () {
      expect(_makeConvocatoria(status: 'active').isOpen, isTrue);
      expect(_makeConvocatoria(status: 'permanent').isOpen, isTrue);
      expect(_makeConvocatoria(status: 'expired').isOpen, isFalse);
      expect(_makeConvocatoria(status: 'pending').isOpen, isFalse);
      expect(_makeConvocatoria(status: 'rejected').isOpen, isFalse);
    });
  });

  group('Convocatoria.statusLabel', () {
    test('returns Spanish label per status', () {
      expect(_makeConvocatoria(status: 'active').statusLabel('es'), 'Activa');
      expect(_makeConvocatoria(status: 'expired').statusLabel('es'), 'Vencida');
      expect(_makeConvocatoria(status: 'draft').statusLabel('es'), 'Borrador');
      expect(_makeConvocatoria(status: 'pending').statusLabel('es'), 'Pendiente');
      expect(_makeConvocatoria(status: 'rejected').statusLabel('es'), 'No aprobada');
      expect(_makeConvocatoria(status: 'permanent').statusLabel('es'), 'Permanente');
    });

    test('returns English label per status', () {
      expect(_makeConvocatoria(status: 'active').statusLabel('en'), 'Active');
      expect(_makeConvocatoria(status: 'expired').statusLabel('en'), 'Expired');
      expect(_makeConvocatoria(status: 'draft').statusLabel('en'), 'Draft');
      expect(_makeConvocatoria(status: 'pending').statusLabel('en'), 'Pending');
      expect(_makeConvocatoria(status: 'rejected').statusLabel('en'), 'Not approved');
      expect(_makeConvocatoria(status: 'permanent').statusLabel('en'), 'Permanent');
    });

    test('returns the raw status for unknown values', () {
      expect(_makeConvocatoria(status: 'mystery').statusLabel('es'), 'mystery');
      expect(_makeConvocatoria(status: 'mystery').statusLabel('en'), 'mystery');
    });
  });

  group('Convocatoria.fromJson', () {
    test('parses minimal required fields', () {
      final c = Convocatoria.fromJson({
        'id': 'abc-123',
        'title_es': 'Hola',
        'title_en': 'Hello',
        'description_es': 'Desc ES',
        'description_en': 'Desc EN',
        'status': 'active',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      });
      expect(c.id, 'abc-123');
      expect(c.titleEs, 'Hola');
      expect(c.titleEn, 'Hello');
      expect(c.status, 'active');
      expect(c.isPublic, isTrue);
      expect(c.currency, 'USD');
    });

    test('parses embedded categories join', () {
      final c = Convocatoria.fromJson({
        'id': 'abc',
        'title_es': 'X',
        'title_en': 'X',
        'description_es': 'X',
        'description_en': 'X',
        'status': 'pending',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
        'categories': {
          'name_es': 'Educación',
          'name_en': 'Education',
          'slug': 'education',
          'icon': 'school',
          'color': '#4F46E5',
        },
      });
      expect(c.categoryNameEs, 'Educación');
      expect(c.categoryNameEn, 'Education');
      expect(c.categorySlug, 'education');
      expect(c.categoryIcon, 'school');
      expect(c.categoryColor, '#4F46E5');
    });
  });
}
