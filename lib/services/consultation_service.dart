import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/consultation.dart';

class ConsultationService extends ChangeNotifier {
  final SupabaseClient? _supabase;
  bool _useSupabase = false;

  final Map<String, List<Consultation>> _consultationsByCustomer = {};
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;
  bool _disposed = false;

  ConsultationService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? _resolveDefaultSupabaseClient() {
    if (_supabase != null) {
      _initSupabase();
    }
  }

  static SupabaseClient? _resolveDefaultSupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  List<Consultation> getConsultationsForCustomer(String customerId) {
    final list = _consultationsByCustomer[customerId] ?? [];
    final sorted = List<Consultation>.from(list);
    sorted.sort((a, b) => b.consultationDate.compareTo(a.consultationDate));
    return sorted;
  }

  Future<void> _initSupabase() async {
    try {
      _useSupabase = true;

      try {
        final List<dynamic> initialRows = await _supabase!
            .from('consultations')
            .select()
            .order('consultation_date', ascending: false);
        for (final row in initialRows) {
          final c = Consultation.fromMap(Map<String, dynamic>.from(row));
          _consultationsByCustomer.putIfAbsent(c.customerId, () => []);
          _consultationsByCustomer[c.customerId]!.add(c);
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Supabase consultations initial fetch error: $e');
      }

      if (_disposed) return;

      _realtimeSubscription = _supabase!
          .from('consultations')
          .stream(primaryKey: ['id'])
          .listen((List<Map<String, dynamic>> rows) {
        _consultationsByCustomer.clear();
        for (final row in rows) {
          final c = Consultation.fromMap(row);
          _consultationsByCustomer.putIfAbsent(c.customerId, () => []);
          _consultationsByCustomer[c.customerId]!.add(c);
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('Supabase consultations stream error: $e');
      });
    } catch (e) {
      debugPrint('Supabase consultations init error: $e');
      _useSupabase = false;
    }
  }

  Future<void> addConsultation(Consultation consultation) async {
    if (_useSupabase && _supabase != null) {
      try {
        final payload = consultation.toSupabaseMap(isInsert: true);
        final res = await _supabase.from('consultations').insert(payload).select();
        if (res.isNotEmpty) {
          final newC = Consultation.fromMap(Map<String, dynamic>.from(res.first));
          _consultationsByCustomer.putIfAbsent(newC.customerId, () => []);
          final exists = _consultationsByCustomer[newC.customerId]!.any((x) => x.id == newC.id);
          if (!exists) {
            _consultationsByCustomer[newC.customerId]!.add(newC);
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('Supabase addConsultation error: $e');
        rethrow;
      }
    } else {
      _consultationsByCustomer.putIfAbsent(consultation.customerId, () => []);
      _consultationsByCustomer[consultation.customerId]!.add(consultation);
      notifyListeners();
    }
  }

  Future<void> updateConsultation(Consultation consultation) async {
    if (_useSupabase && _supabase != null) {
      try {
        final payload = consultation.toSupabaseMap(isInsert: false);
        await _supabase.from('consultations').update(payload).eq('id', consultation.id);
        final list = _consultationsByCustomer[consultation.customerId];
        if (list != null) {
          final idx = list.indexWhere((c) => c.id == consultation.id);
          if (idx != -1) {
            list[idx] = consultation;
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('Supabase updateConsultation error: $e');
        rethrow;
      }
    } else {
      final list = _consultationsByCustomer[consultation.customerId];
      if (list != null) {
        final idx = list.indexWhere((c) => c.id == consultation.id);
        if (idx != -1) {
          list[idx] = consultation;
          notifyListeners();
        }
      }
    }
  }

  Future<void> deleteConsultation(Consultation consultation) async {
    if (_useSupabase && _supabase != null) {
      try {
        await _supabase.from('consultations').delete().eq('id', consultation.id);
        final list = _consultationsByCustomer[consultation.customerId];
        if (list != null) {
          list.removeWhere((c) => c.id == consultation.id);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Supabase deleteConsultation error: $e');
        rethrow;
      }
    } else {
      final list = _consultationsByCustomer[consultation.customerId];
      if (list != null) {
        list.removeWhere((c) => c.id == consultation.id);
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
