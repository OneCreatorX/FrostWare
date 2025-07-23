

-- AÑADE ESTE CÓDIGO AL FINAL DEL SCRIPT PARA CREAR LAS PESTAÑAS

-- Crear la pestaña "Scripts"
fw.addTab(
    "Scripts", -- Nombre interno de la pestaña
    "Scripts", -- Texto que se mostrará en el botón de la barra lateral
    "rbxassetid://107390243416427", -- ID del icono (ejemplo: el mismo que Console)
    UDim2.new(0.075, 0, 0.44, 0), -- Posición del botón en la barra lateral (ajusta según necesites)
    fw.cscp -- Función que crea la página de contenido para esta pestaña
)

-- Crear la pestaña "Test"
fw.addTab(
    "Test", -- Nombre interno de la pestaña
    "Test", -- Texto que se mostrará en el botón de la barra lateral
    "rbxassetid://128679881757557", -- ID del icono (ejemplo: el mismo que Extra)
    UDim2.new(0.075, 0, 0.52, 0), -- Posición del botón en la barra lateral (ajusta según necesites)
    fw.cstp -- Función que crea la página de contenido para esta pestaña
)
