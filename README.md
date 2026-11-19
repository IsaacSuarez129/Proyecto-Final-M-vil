# PVM - Punto de Venta Móvil

Sistema de Punto de Venta (POS) para tablets, desarrollado como proyecto
universitario con Flutter y Supabase.

> **Estado:** en desarrollo. Ya cuenta con la interfaz principal, la conexión con Supabase
> para autenticación, perfiles de cajero con foto desde cámara, apertura de turno,
> catálogo de productos, gestor multi-ticket (hasta 5 ventas simultáneas),
> registro de ventas y generación de ticket digital en PDF; el resto de módulos se agregan por etapas.

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
- [x] Gestor multi-ticket (hasta 5 tickets abiertos guardados localmente con SharedPreferences)
- [x] Cobro, registro de venta en Supabase y ticket digital en PDF

Pendiente:
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