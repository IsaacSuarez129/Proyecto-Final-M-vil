# PVM - Punto de Venta Móvil

Sistema de Punto de Venta (POS) para tablets, desarrollado como proyecto
universitario con Flutter y Supabase.

> **Estado:** en desarrollo. Ya cuenta con la interfaz principal, la conexión con Supabase
> para autenticación, perfiles de cajero y apertura de turno y
> el catálogo de productos junto al carrito activo; el resto de módulos se agregan por etapas.

## Funcionalidades

Implementado:
- [x] Estructura del proyecto por features
- [x] Pantalla principal: lista de productos, cuadrícula de botones, panel de
      Total / Pago / Cambio con teclado numérico y botón de cobrar
- [x] Diseño adaptable a distintos tamaños de pantalla (SafeArea y layout
      compacto/amplio)
- [x] Login de administrador (Google / Email)
- [x] Cambio rápido de turno para cajeros (perfil + PIN de 4 dígitos)
- [x] Apertura de turno con registro de saldo inicial en caja
- [x] Catálogo de productos desde Supabase
- [x] Carrito activo guardado localmente (SharedPreferences)

Pendiente:
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

Se recomienda probar en una tablet o emulador de tablet en horizontal.

## Comando para cerrar sesión en lo que se anexa esa función
update public.shifts set closed_at = now() where closed_at is null;

## Autor

Isaac Suárez