# 📊 Ejemplos de Trazabilidad - Sistema de Gestión de Almacén y Obras

## 🎯 **1. GESTIÓN DE ARTÍCULOS**

### **Ejemplo 1: Creación de Artículo**
```
📅 Fecha: 15/01/2024 09:30:15
👤 Usuario: admin@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "CEM001" - Cemento Portland 25kg
💰 Precio: 8.50€
📍 Ubicación: Almacén 1, Estantería A-3
📊 Stock inicial: 100 unidades
✅ Estado: Activo
🔗 Trazabilidad: Artículo creado desde pantalla "Nuevo Artículo"
```

### **Ejemplo 2: Actualización de Precio**
```
📅 Fecha: 20/01/2024 14:22:08
👤 Usuario: jefe.almacen@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "CEM001" - Cemento Portland 25kg
💰 Precio anterior: 8.50€ → Nuevo: 9.20€
📈 Incremento: +8.24%
📝 Motivo: Aumento coste proveedor
🔗 Trazabilidad: Actualización desde "Editar Artículo"
```

### **Ejemplo 3: Baja de Artículo**
```
📅 Fecha: 25/01/2024 11:45:33
👤 Usuario: admin@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "LAD001" - Ladrillos cerámicos
❌ Estado: Desactivado
📝 Motivo: Producto discontinuado por proveedor
🔗 Trazabilidad: Baja desde "Gestión de Artículos"
```

### **Ejemplo 4: Cambio de Ubicación**
```
📅 Fecha: 28/01/2024 16:15:42
👤 Usuario: operario1@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "VAR001" - Varillas acero 12mm
📍 Ubicación anterior: Almacén 2, Estantería B-1
📍 Nueva ubicación: Almacén 1, Estantería A-5
📝 Motivo: Reorganización almacén
🔗 Trazabilidad: Cambio desde "Traspasos Internos"
```

### **Ejemplo 5: Actualización de Stock Mínimo**
```
📅 Fecha: 30/01/2024 10:30:15
👤 Usuario: jefe.almacen@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "CEM001" - Cemento Portland 25kg
📊 Stock mínimo anterior: 20 unidades
📊 Nuevo stock mínimo: 50 unidades
📝 Motivo: Aumento demanda prevista
🔗 Trazabilidad: Actualización desde "Configuración de Artículo"
```

---

## 📥 **2. GESTIÓN DE ENTRADAS**

### **Ejemplo 1: Entrada por Compra**
```
📅 Fecha: 15/01/2024 08:45:22
👤 Usuario: compras@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "CEM001" - Cemento Portland 25kg
📊 Cantidad: 200 unidades
💰 Precio unitario: 8.50€
💰 Total: 1,700.00€
🚚 Proveedor: Cementos del Norte S.A.
📋 Albarán: ALB-2024-001
🔗 Trazabilidad: Entrada desde "Entradas de Inventario"
```

### **Ejemplo 2: Entrada por Devolución**
```
📅 Fecha: 18/01/2024 13:20:15
👤 Usuario: jefe.obra@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "LAD001" - Ladrillos cerámicos
📊 Cantidad: 50 unidades
💰 Precio unitario: 0.45€
💰 Total: 22.50€
🏗️ Obra origen: Obra "Residencia Los Pinos"
📝 Motivo: Material sobrante
🔗 Trazabilidad: Entrada desde "Devoluciones de Obra"
```

### **Ejemplo 3: Entrada por Ajuste de Inventario**
```
📅 Fecha: 22/01/2024 09:15:30
👤 Usuario: auditor@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "VAR001" - Varillas acero 12mm
📊 Cantidad: 15 unidades
💰 Precio unitario: 12.80€
💰 Total: 192.00€
📝 Motivo: Diferencia encontrada en inventario físico
🔗 Trazabilidad: Ajuste desde "Inventario Físico"
```

### **Ejemplo 4: Entrada por Producción**
```
📅 Fecha: 25/01/2024 16:45:18
👤 Usuario: produccion@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "HOR001" - Hormigón H-25
📊 Cantidad: 5 m³
💰 Precio unitario: 85.00€
💰 Total: 425.00€
🏭 Origen: Planta de hormigón propia
📝 Motivo: Producción interna
🔗 Trazabilidad: Entrada desde "Producción Interna"
```

### **Ejemplo 5: Entrada por Escaneo de Albarán**
```
📅 Fecha: 28/01/2024 11:30:45
👤 Usuario: recepcion@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículos: 15 artículos diferentes
📊 Total unidades: 1,250
💰 Valor total: 8,750.00€
🚚 Proveedor: Materiales del Sur S.L.
📋 Albarán: ALB-2024-045
📱 Método: Escaneo automático de códigos
🔗 Trazabilidad: Entrada desde "Recepción por Escáner"
```

---

## 📤 **3. GESTIÓN DE SALIDAS**

### **Ejemplo 1: Salida para Obra**
```
📅 Fecha: 16/01/2024 07:30:12
👤 Usuario: jefe.obra@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "CEM001" - Cemento Portland 25kg
📊 Cantidad: 50 unidades
💰 Precio unitario: 8.50€
💰 Total: 425.00€
🏗️ Destino: Obra "Residencia Los Pinos"
📋 Orden trabajo: OT-2024-012
🔗 Trazabilidad: Salida desde "Salidas de Inventario"
```

### **Ejemplo 2: Salida por Venta**
```
📅 Fecha: 19/01/2024 14:15:33
👤 Usuario: ventas@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "LAD001" - Ladrillos cerámicos
📊 Cantidad: 500 unidades
💰 Precio unitario: 0.45€
💰 Total: 225.00€
👤 Cliente: Constructora Beta S.L.
📋 Factura: FAC-2024-089
🔗 Trazabilidad: Salida desde "Ventas"
```

### **Ejemplo 3: Salida por Traspaso**
```
📅 Fecha: 23/01/2024 10:45:27
👤 Usuario: almacen@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "VAR001" - Varillas acero 12mm
📊 Cantidad: 100 unidades
💰 Precio unitario: 12.80€
💰 Total: 1,280.00€
📍 Destino: Almacén 2
📋 Traspaso: TRA-2024-007
🔗 Trazabilidad: Salida desde "Traspasos Internos"
```

### **Ejemplo 4: Salida por Ajuste**
```
📅 Fecha: 26/01/2024 15:20:44
👤 Usuario: auditor@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículo: Código "CEM001" - Cemento Portland 25kg
📊 Cantidad: 5 unidades
💰 Precio unitario: 8.50€
💰 Total: 42.50€
📝 Motivo: Pérdida por humedad
🔗 Trazabilidad: Ajuste desde "Inventario Físico"
```

### **Ejemplo 5: Salida por Escaneo**
```
📅 Fecha: 29/01/2024 12:15:18
👤 Usuario: operario2@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📦 Artículos: 8 artículos diferentes
📊 Total unidades: 75
💰 Valor total: 1,250.00€
🏗️ Destino: Obra "Edificio Central"
📱 Método: Escaneo de códigos de barras
🔗 Trazabilidad: Salida desde "Escáner de Salidas"
```

---

## 🏗️ **4. GESTIÓN DE OBRAS**

### **Ejemplo 1: Creación de Obra**
```
📅 Fecha: 10/01/2024 09:00:00
👤 Usuario: director@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🏗️ Obra: "Residencia Los Pinos"
📍 Ubicación: Calle Mayor 123, Madrid
💰 Presupuesto: 2,500,000.00€
📅 Fecha inicio: 15/01/2024
📅 Fecha fin prevista: 15/12/2024
👷 Jefe obra: Juan Pérez
🔗 Trazabilidad: Obra creada desde "Nueva Obra"
```

### **Ejemplo 2: Asignación de Materiales**
```
📅 Fecha: 20/01/2024 08:30:15
👤 Usuario: jefe.obra@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🏗️ Obra: "Residencia Los Pinos"
📦 Materiales: 12 artículos diferentes
📊 Total unidades: 1,500
💰 Valor asignado: 15,750.00€
📋 Orden: OT-2024-015
🔗 Trazabilidad: Asignación desde "Gestión de Obra"
```

### **Ejemplo 3: Actualización de Progreso**
```
📅 Fecha: 25/01/2024 17:45:22
👤 Usuario: jefe.obra@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🏗️ Obra: "Residencia Los Pinos"
📊 Progreso anterior: 15%
📊 Nuevo progreso: 25%
📝 Actividad: Cimentación completada
💰 Coste acumulado: 625,000.00€
🔗 Trazabilidad: Actualización desde "Seguimiento de Obra"
```

### **Ejemplo 4: Finalización de Obra**
```
📅 Fecha: 10/12/2024 16:30:00
👤 Usuario: director@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🏗️ Obra: "Residencia Los Pinos"
✅ Estado: Completada
💰 Coste final: 2,450,000.00€
💰 Ahorro: 50,000.00€ (2%)
📅 Fecha fin real: 10/12/2024
🔗 Trazabilidad: Finalización desde "Cierre de Obra"
```

### **Ejemplo 5: Devolución de Materiales**
```
📅 Fecha: 12/12/2024 10:15:30
👤 Usuario: jefe.obra@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🏗️ Obra: "Residencia Los Pinos"
📦 Materiales devueltos: 5 artículos
📊 Total unidades: 150
💰 Valor devuelto: 2,250.00€
📝 Motivo: Material sobrante
🔗 Trazabilidad: Devolución desde "Cierre de Obra"
```

---

## ✅ **5. GESTIÓN DE TAREAS**

### **Ejemplo 1: Creación de Tarea**
```
📅 Fecha: 15/01/2024 09:15:30
👤 Usuario: supervisor@empresa.com
🏢 Empresa: Construcciones ABC S.L.
✅ Tarea: "Revisar stock de cemento"
📍 Zona: Almacén 1
👥 Responsables: [operario1@empresa.com, operario2@empresa.com]
📊 Prioridad: Alta
📅 Fecha límite: 16/01/2024 17:00:00
🔄 Repetición: No repetir
🔗 Trazabilidad: Tarea creada desde "Nueva Tarea"
```

### **Ejemplo 2: Asignación de Responsables**
```
📅 Fecha: 15/01/2024 09:20:15
👤 Usuario: supervisor@empresa.com
🏢 Empresa: Construcciones ABC S.L.
✅ Tarea: "Revisar stock de cemento"
👥 Responsables añadidos: [jefe.almacen@empresa.com]
📝 Motivo: Necesaria supervisión técnica
🔗 Trazabilidad: Asignación desde "Editar Tarea"
```

### **Ejemplo 3: Cambio de Estado**
```
📅 Fecha: 15/01/2024 14:30:45
👤 Usuario: operario1@empresa.com
🏢 Empresa: Construcciones ABC S.L.
✅ Tarea: "Revisar stock de cemento"
📊 Estado anterior: Pendiente
📊 Nuevo estado: En Progreso
📝 Comentario: Iniciando revisión física
🔗 Trazabilidad: Cambio desde "Lista de Tareas"
```

### **Ejemplo 4: Completar Tarea**
```
📅 Fecha: 16/01/2024 16:45:22
👤 Usuario: jefe.almacen@empresa.com
🏢 Empresa: Construcciones ABC S.L.
✅ Tarea: "Revisar stock de cemento"
📊 Estado: Completada
📝 Resultado: Stock verificado, 2 unidades faltantes detectadas
📅 Fecha completada: 16/01/2024 16:45:22
🔗 Trazabilidad: Completada desde "Detalle de Tarea"
```

### **Ejemplo 5: Tarea Recurrente**
```
📅 Fecha: 20/01/2024 08:00:00
👤 Usuario: sistema@empresa.com
🏢 Empresa: Construcciones ABC S.L.
✅ Tarea: "Inventario semanal"
📍 Zona: Almacén 1
👥 Responsables: [operario1@empresa.com]
📊 Prioridad: Media
🔄 Repetición: Semanal
📅 Próxima ejecución: 27/01/2024 08:00:00
🔗 Trazabilidad: Generada automáticamente por sistema
```

---

## 🚚 **6. GESTIÓN DE PROVEEDORES**

### **Ejemplo 1: Registro de Proveedor**
```
📅 Fecha: 10/01/2024 10:30:15
👤 Usuario: compras@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🚚 Proveedor: "Cementos del Norte S.A."
📧 Email: contacto@cementosnorte.com
📞 Teléfono: +34 91 123 4567
📍 Dirección: Polígono Industrial Norte, Madrid
✅ Estado: Activo
🔗 Trazabilidad: Registro desde "Nuevo Proveedor"
```

### **Ejemplo 2: Actualización de Datos**
```
📅 Fecha: 15/01/2024 14:20:30
👤 Usuario: compras@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🚚 Proveedor: "Cementos del Norte S.A."
📞 Teléfono anterior: +34 91 123 4567
📞 Nuevo teléfono: +34 91 987 6543
📝 Motivo: Cambio de centralita
🔗 Trazabilidad: Actualización desde "Editar Proveedor"
```

### **Ejemplo 3: Desactivación de Proveedor**
```
📅 Fecha: 20/01/2024 11:45:18
👤 Usuario: director@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🚚 Proveedor: "Materiales Antiguos S.L."
❌ Estado: Desactivado
📝 Motivo: Proveedor cesó actividad
🔗 Trazabilidad: Desactivación desde "Gestión de Proveedores"
```

### **Ejemplo 4: Evaluación de Proveedor**
```
📅 Fecha: 25/01/2024 16:30:45
👤 Usuario: compras@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🚚 Proveedor: "Cementos del Norte S.A."
⭐ Calificación: 4.5/5
📝 Comentarios: Excelente servicio, entregas puntuales
📊 Pedidos últimos 3 meses: 15
💰 Volumen facturado: 45,000.00€
🔗 Trazabilidad: Evaluación desde "Historial de Proveedor"
```

### **Ejemplo 5: Reactivación de Proveedor**
```
📅 Fecha: 30/01/2024 09:15:22
👤 Usuario: compras@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🚚 Proveedor: "Materiales Antiguos S.L."
✅ Estado: Reactivado
📝 Motivo: Proveedor reanudó actividad con nuevas condiciones
🔗 Trazabilidad: Reactivación desde "Gestión de Proveedores"
```

---

## 👥 **7. GESTIÓN DE CLIENTES**

### **Ejemplo 1: Registro de Cliente**
```
📅 Fecha: 12/01/2024 11:20:15
👤 Usuario: ventas@empresa.com
🏢 Empresa: Construcciones ABC S.L.
👤 Cliente: "Constructora Beta S.L."
📧 Email: pedidos@constructorabeta.com
📞 Teléfono: +34 91 555 1234
📍 Dirección: Avenida Principal 456, Barcelona
✅ Estado: Activo
🔗 Trazabilidad: Registro desde "Nuevo Cliente"
```

### **Ejemplo 2: Actualización de Contacto**
```
📅 Fecha: 18/01/2024 15:45:30
👤 Usuario: ventas@empresa.com
🏢 Empresa: Construcciones ABC S.L.
👤 Cliente: "Constructora Beta S.L."
📧 Email anterior: pedidos@constructorabeta.com
📧 Nuevo email: compras@constructorabeta.com
📝 Motivo: Cambio de departamento de compras
🔗 Trazabilidad: Actualización desde "Editar Cliente"
```

### **Ejemplo 3: Historial de Compras**
```
📅 Fecha: 25/01/2024 10:30:45
👤 Usuario: sistema@empresa.com
🏢 Empresa: Construcciones ABC S.L.
👤 Cliente: "Constructora Beta S.L."
📊 Compras últimos 6 meses: 25 pedidos
💰 Volumen total: 125,000.00€
📦 Artículo más comprado: Ladrillos cerámicos (5,000 unidades)
🔗 Trazabilidad: Generado automáticamente por sistema
```

### **Ejemplo 4: Cliente Inactivo**
```
📅 Fecha: 28/01/2024 14:15:18
👤 Usuario: ventas@empresa.com
🏢 Empresa: Construcciones ABC S.L.
👤 Cliente: "Obras Pequeñas S.L."
❌ Estado: Inactivo
📝 Motivo: Sin actividad desde hace 6 meses
🔗 Trazabilidad: Desactivación automática por sistema
```

### **Ejemplo 5: Reactivación de Cliente**
```
📅 Fecha: 30/01/2024 16:20:33
👤 Usuario: ventas@empresa.com
🏢 Empresa: Construcciones ABC S.L.
👤 Cliente: "Obras Pequeñas S.L."
✅ Estado: Reactivado
📝 Motivo: Nuevo proyecto iniciado
🔗 Trazabilidad: Reactivación desde "Gestión de Clientes"
```

---

## 📋 **8. GESTIÓN DE ALBARANES**

### **Ejemplo 1: Creación de Albarán**
```
📅 Fecha: 15/01/2024 08:30:15
👤 Usuario: recepcion@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📋 Albarán: ALB-2024-001
🚚 Proveedor: "Cementos del Norte S.A."
📦 Líneas: 8 artículos diferentes
📊 Total unidades: 1,200
💰 Valor total: 8,500.00€
📊 Estado: Pendiente
🔗 Trazabilidad: Creado desde "Nuevo Albarán"
```

### **Ejemplo 2: Recepción por Escáner**
```
📅 Fecha: 15/01/2024 09:45:22
👤 Usuario: recepcion@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📋 Albarán: ALB-2024-001
📱 Método: Escaneo de códigos de barras
📦 Artículos escaneados: 8/8
✅ Estado: Completado
🔗 Trazabilidad: Recepción desde "Escáner de Albarán"
```

### **Ejemplo 3: Procesamiento de Albarán**
```
📅 Fecha: 15/01/2024 10:15:30
👤 Usuario: jefe.almacen@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📋 Albarán: ALB-2024-001
📊 Estado: Procesado
📦 Stock actualizado: 8 artículos
💰 Entradas registradas: 8,500.00€
🔗 Trazabilidad: Procesado desde "Lista de Albaranes"
```

### **Ejemplo 4: Albarán Parcial**
```
📅 Fecha: 20/01/2024 11:30:45
👤 Usuario: recepcion@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📋 Albarán: ALB-2024-005
📦 Líneas totales: 12
📦 Líneas recibidas: 10
📦 Líneas pendientes: 2
📊 Estado: Parcial
📝 Motivo: Falta de stock en proveedor
🔗 Trazabilidad: Recepción parcial desde "Escáner"
```

### **Ejemplo 5: Importación CSV**
```
📅 Fecha: 25/01/2024 14:20:18
👤 Usuario: compras@empresa.com
🏢 Empresa: Construcciones ABC S.L.
📋 Albarán: ALB-2024-010
📁 Método: Importación CSV
📦 Líneas importadas: 15
❌ Códigos no encontrados: 2
✅ Códigos resueltos: 2
📊 Estado: Completado
🔗 Trazabilidad: Importación desde "Crear Albarán"
```

---

## ⚙️ **9. CONFIGURACIÓN Y AJUSTES**

### **Ejemplo 1: Cambio de Configuración**
```
📅 Fecha: 10/01/2024 09:00:00
👤 Usuario: admin@empresa.com
🏢 Empresa: Construcciones ABC S.L.
⚙️ Configuración: Formato de código de barras
📊 Valor anterior: EAN13
📊 Nuevo valor: Code128
📝 Motivo: Mejor compatibilidad con escáneres
🔗 Trazabilidad: Cambio desde "Ajustes"
```

### **Ejemplo 2: Configuración de Notificaciones**
```
📅 Fecha: 15/01/2024 14:30:15
👤 Usuario: jefe.almacen@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🔔 Notificaciones: Stock mínimo
✅ Estado: Activado
📊 Umbral: 20 unidades
📧 Destinatarios: [jefe.almacen@empresa.com, compras@empresa.com]
🔗 Trazabilidad: Configuración desde "Ajustes"
```

### **Ejemplo 3: Cambio de Tema**
```
📅 Fecha: 20/01/2024 16:45:30
👤 Usuario: operario1@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🎨 Tema: Apariencia de la aplicación
📊 Tema anterior: Claro
📊 Nuevo tema: Oscuro
📝 Motivo: Mejor visibilidad en exteriores
🔗 Trazabilidad: Cambio desde "Ajustes"
```

### **Ejemplo 4: Configuración de Sincronización**
```
📅 Fecha: 25/01/2024 11:15:22
👤 Usuario: admin@empresa.com
🏢 Empresa: Construcciones ABC S.L.
🔄 Sincronización: Automática
✅ Estado: Activada
⏰ Frecuencia: Cada 30 minutos
📱 Modo offline: Habilitado
🔗 Trazabilidad: Configuración desde "Ajustes"
```

### **Ejemplo 5: Gestión de Usuarios**
```
📅 Fecha: 30/01/2024 10:30:45
👤 Usuario: admin@empresa.com
🏢 Empresa: Construcciones ABC S.L.
👤 Usuario: nuevo.operario@empresa.com
✅ Acción: Usuario creado
🔐 Permisos: Operario de almacén
📊 Estado: Activo
🔗 Trazabilidad: Gestión desde "Ajustes > Usuarios"
```

---

## 📊 **RESUMEN DE TRAZABILIDAD**

### **Elementos Rastreados:**
- ✅ **Usuarios**: Quién realizó cada acción
- ✅ **Fechas y Horas**: Cuándo ocurrió cada evento
- ✅ **Empresas**: En qué contexto se realizó
- ✅ **Acciones**: Qué operación se ejecutó
- ✅ **Datos**: Valores anteriores y nuevos
- ✅ **Motivos**: Por qué se realizó la acción
- ✅ **Origen**: Desde qué pantalla/funcionalidad
- ✅ **Estados**: Cambios de estado de elementos
- ✅ **Valores**: Cantidades, precios, totales
- ✅ **Relaciones**: Conexiones entre entidades

### **Beneficios de la Trazabilidad:**
- 🔍 **Auditoría completa** de todas las operaciones
- 📈 **Análisis de tendencias** y patrones de uso
- 🛡️ **Seguridad** y control de accesos
- 📊 **Reportes detallados** para la dirección
- 🔧 **Resolución de incidencias** más rápida
- 📋 **Cumplimiento normativo** y legal
- 💡 **Optimización** de procesos internos
- 🎯 **Mejora continua** del sistema
