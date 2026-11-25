import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_mecanica/main.dart';

Future<void> preencher(
    WidgetTester t, String veiculo, String placa, String servico) async {
  final campos = find.byType(TextFormField);
  await t.enterText(campos.at(0), veiculo);
  await t.enterText(campos.at(1), placa);
  await t.enterText(campos.at(2), servico);
}

void main() {
  testWidgets('cadastro, validação, edição e exclusão', (t) async {
    await t.pumpWidget(const OficinaApp());
    expect(find.text('Nenhum registro cadastrado.'), findsOneWidget);

    // Validação: campos só com espaços não salvam
    await t.tap(find.text('Novo registro'));
    await t.pumpAndSettle();
    await preencher(t, '   ', 'ABC1D23', 'Revisão');
    await t.tap(find.text('Salvar'));
    await t.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsOneWidget);

    // Cadastro
    await preencher(t, 'Civic', 'ABC1D23', 'Revisão');
    await t.tap(find.text('Salvar'));
    await t.pumpAndSettle();
    expect(find.text('Civic'), findsOneWidget);

    // Edição sem duplicar
    await t.tap(find.text('Civic'));
    await t.pumpAndSettle();
    await preencher(t, 'Corolla', 'ABC1D23', 'Revisão');
    await t.tap(find.text('Salvar'));
    await t.pumpAndSettle();
    expect(find.text('Corolla'), findsOneWidget);
    expect(find.text('Civic'), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);

    // Exclusão
    await t.tap(find.byIcon(Icons.delete));
    await t.pumpAndSettle();
    await t.tap(find.text('Excluir'));
    await t.pumpAndSettle();
    expect(find.text('Nenhum registro cadastrado.'), findsOneWidget);
  });
}
