# PVM - Punto de Venta Móvil

Sistema de Punto de Venta (POS) para tablets, desarrollado como proyecto
universitario con Flutter y Supabase.

> **Estado:** en desarrollo. Por ahora está implementada la interfaz principal;
> la lógica y la conexión con el backend se agregan por etapas.

## Funcionalidades

Implementado:
- [x] Estructura del proyecto por features
- [x] Pantalla principal: lista de productos, cuadrícula de botones, panel de
      Total / Pago / Cambio con teclado numérico y botón de cobrar
- [x] Diseño adaptable a distintos tamaños de pantalla (SafeArea y layout
      compacto/amplio)

Pendiente:
- [ ] Login de administrador (Google / Email)
- [ ] Cambio rápido de turno para cajeros (perfil + PIN de 4 dígitos)
- [ ] Catálogo de productos desde Supabase
- [ ] Carrito activo guardado localmente (SharedPreferences)
- [ ] Cobro, guardado de la venta y ticket digital en PDF
- [ ] Corte de caja: apertura, gastos rápidos y cierre de turno
- [ ] Exportación del corte a PDF y CSV
- [ ] Dashboard de estadísticas de ingresos

## Tecnologías

- Flutter / Dart
- Supabase (Auth, Database y Storage)
- Riverpod (estado)
- go_router (navegación)
- SharedPreferences (carrito local)
- pdf y csv (exportación)
- fl_chart (gráficas)

## Cómo ejecutar

Requisitos: Flutter SDK instalado.

```bash
git clone https://github.com/TU_USUARIO/TU_REPO.git
cd TU_REPO
flutter pub get
flutter run
```

Se recomienda probar en una tablet o emulador de tablet en horizontal.


## Autor

Isaac Suárez