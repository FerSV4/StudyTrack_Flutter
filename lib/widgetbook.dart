import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:studytrack_design_system/studytrack_design_system.dart';

void main() {
  runApp(const StudyTrackWidgetbook());
}

class StudyTrackWidgetbook extends StatelessWidget {
  const StudyTrackWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookCategory(
          name: 'Design System StudyTrack',
          children: [
            WidgetbookFolder(
              name: 'Botones',
              children: [
                WidgetbookComponent(
                  name: 'StButton',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Primario',
                      builder: (context) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: StButton(
                            text: context.knobs.string(
                              label: 'Texto del botón',
                              initialValue: 'Guardar Tarea',
                            ),
                            isLoading: context.knobs.boolean(
                              label: 'Estado de carga (isLoading)',
                              initialValue: false,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            WidgetbookFolder(
              name: 'Tarjetas',
              children: [
                WidgetbookComponent(
                  name: 'StCard',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Contenedor Básico',
                      builder: (context) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: StCard(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                context.knobs.string(
                                  label: 'Texto modificable',
                                  initialValue: 'Contenido de la StCard',
                                ),
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            WidgetbookFolder(
              name: 'Formularios',
              children: [
                WidgetbookComponent(
                  name: 'StTextField',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Campo de Texto',
                      builder: (context) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: StTextField(
                            label: context.knobs.string(
                              label: 'Etiqueta (label)',
                              initialValue: 'Nombre de la Materia',
                            ),
                            hint: context.knobs.string(
                              label: 'Texto de ayuda (hint)',
                              initialValue: 'Plataformas Moviles',
                            ),
                            readOnly: context.knobs.boolean(
                              label: 'Solo lectura',
                              initialValue: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'StColorPicker',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Selector de Color',
                      builder: (context) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: StColorPicker(
                            selectedColorHex: context.knobs.string(
                              label: 'Color',
                              initialValue: '#5073be',
                            ),
                            onColorSelected: (color) {},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}