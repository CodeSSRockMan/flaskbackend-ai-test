def tick(args)
  # Inicialización del juego (solo se hace una vez)
  args.state.time_left ||= 20
  
  args.state.slimes ||= []
  args.state.game_over ||= false
  args.state.slimes_collected ||= 0
  args.state.animation_counter ||= 0  # Contador para controlar la animación
  args.state.animation_speed ||= 5  # Velocidad de la animación, cada cuántos ticks cambia un frame
  args.state.background_drawn ||= false
  args.state.number_of_slimes ||= 0
  args.state.menu ||= false
  args.state.show_creditss ||= false
  args.state.last_tick ||= args.state.tick_count # Guardar el tick inicial

    draw_background(args)


  load_font(args)

# Asegurarse de que la música solo se cargue una vez
  if args.state.tick_count == 1
    args.state.menu ||= true
    #ir al menu una vez
    # Usar :audio en lugar de :sounds para música en bucle
    args.audio[:music] = { input: "assets/music/caketown.mp3", looping: true }
    args.state.music_playing = true
  end
if args.state.menu
    # Mostrar el menú
    show_menu(args)

    
else

  # Si el juego ha terminado, mostramos el mensaje de Game Over
  if args.state.game_over
    display_game_over(args)
  else
    # Actualizamos el tiempo solo si el juego no ha terminado
    update_time(args)
    
    # Actualizamos el juego si el tiempo no se ha agotado
    if args.state.time_left > 0
      update_game(args)
    else
      args.state.game_over = true  # Termina el juego cuando el tiempo llega a 0
    end

    # Dibujamos los slimes, el tiempo restante y los slimes recolectados
    draw_slimes(args)
    draw_time_left(args)
    draw_slimes_collected(args)
  end
end
end

def show_menu(args)
  # Fondo del menú
  args.outputs.solids << [0, 0, args.grid.w, args.grid.h, 0, 0, 0]  # Fondo negro

  # Si estamos en el menú principal (no mostrando créditos)
  if !args.state.show_creditss

  # Título
  args.outputs.labels << {
    x: args.grid.w / 2, y: args.grid.h - 200,
    text: "Slime Collector",
    alignment_enum: 1, size_enum: 30, r: 255, g: 215, b: 0, a: 255  # Color dorado
  }

  # Instrucciones
  args.outputs.labels << {
    x: args.grid.w / 2, y: args.grid.h- 400,
    text: "Collect all the slimes before time runs out!",
    alignment_enum: 1, size_enum: 12, r: 255, g: 255, b: 255, a: 255  # Blanco
  }

  # Nueva instrucción para succionar slimes
  args.outputs.labels << {
    x: args.grid.w / 2, y: args.grid.h - 450,
    text: "Hold Left Mouse Button to vacuum slimes",
    alignment_enum: 1, size_enum: 12, r: 255, g: 255, b: 255, a: 255  # Blanco
  }

  # Espacio entre la instrucción y el siguiente texto
  args.outputs.labels << {
    x: args.grid.w / 2, y: args.grid.h / 2 - 180,
    text: "Press Space or Enter to Start",
    alignment_enum: 1, size_enum: 8, r: 255, g: 255, b: 255, a: 255  # Blanco
  }

  # Tecla para ver los créditos
  args.outputs.labels << {
    x: args.grid.w / 2, y: args.grid.h / 2 - 230,
    text: "Press C for Credits",
    alignment_enum: 1, size_enum: 8, r: 255, g: 255, b: 255, a: 255  # Blanco
  }


      # Detectar si el jugador presiona para ver los créditos
      if args.inputs.keyboard.key_down.c
          # Reproducir sonido 
  args.audio[:sfxmenu] = { input: 'assets/sounds/sfxmenu.wav', finish: :delete }
        args.state.show_creditss = true  # Mostrar los créditos
      end

  # Detectar si el jugador presiona para comenzar el juego
  if args.inputs.keyboard.key_down.space || args.inputs.keyboard.key_down.enter
    args.state.menu = false  # Salir del menú y comenzar el juego
      # Reproducir sonido 
  args.audio[:sfxmenu] = { input: 'assets/sounds/sfxmenu.wav', finish: :delete }
  end

elsif args.state.show_creditss
  # Llamar a la función que muestra los créditos
  show_credits(args)
end
end

def show_credits(args)
  # Fondo negro
  args.outputs.solids << [0, 0, args.grid.w, args.grid.h, 0, 0, 0]  # Fondo negro

  # Créditos
  args.outputs.labels << {
    x: args.grid.w / 2, y: args.grid.h - 100,
    text: "Credits",
    alignment_enum: 1, size_enum: 30, r: 255, g: 215, b: 0, a: 255
  }
  args.outputs.labels << {
  x: args.grid.w / 2, y: args.grid.h - 200,
  text: "Developer: SSRockMan",
  alignment_enum: 1, size_enum: 12, r: 255, g: 255, b: 255, a: 255
}

  args.outputs.labels << {
    x: args.grid.w / 2, y: args.grid.h - 300,
    text: "Music: Caketown by CutePlayful",
    alignment_enum: 1, size_enum: 12, r: 255, g: 255, b: 255, a: 255
  }
  args.outputs.labels << {
    x: args.grid.w / 2, y: args.grid.h - 400,
    text: "Press Escape to return",
    alignment_enum: 1, size_enum: 12, r: 255, g: 255, b: 255, a: 255
  }

  # Detectar si el jugador presiona Escape para volver al menú
  if args.inputs.keyboard.key_down.escape
    args.state.show_creditss = false  # Regresar al menú principal

      # Reproducir sonido 
  args.audio[:sfxmenu] = { input: 'assets/sounds/sfxmenu.wav', finish: :delete }
  end
end

def update_time(args)
  # Reducimos el tiempo en 1 solo si ha pasado 1 segundo (60 ticks)
  if args.state.tick_count - args.state.last_tick >= 60
    args.state.time_left = [args.state.time_left - 1, 0].max
    args.state.last_tick = args.state.tick_count
  end
end
def update_game(args)
  # Si no hay slimes, generamos nuevos
  generate_initial_slimes(args) if args.state.slimes.empty?

  # Mover los slimes aleatoriamente
  move_slimes_randomly(args)

  # Verificamos si el jugador está manteniendo clic en el mouse para aspirar
  if args.inputs.mouse.button_left
    vacuum_slimes(args)
    collect_slimes(args)  # Absorber slimes si están en contacto con el mouse
  end
end

def generate_initial_slimes(args)
  # Generamos 5 slimes iniciales con tamaño más grande y colores aleatorios
  args.state.number_of_slimes += 3;
  number_of_slimes = args.state.number_of_slimes;
  number_of_slimes.times do
    # Usamos un color aleatorio basado en los nombres de las carpetas
    slime_color = ["aquamarineslime", "blueslime", "bluegreenslime", "darkblueslime", 
               "goldslime", "greenslime", "lightblueslime", "maroonslime", 
               "orangeslime", "palegreenslime", "pinkslime", "purpleslime", 
               "redslime", "violetslime"].sample

    args.state.slimes << {
      x: rand(args.grid.w - 30),  # Posición aleatoria en X dentro de la pantalla
      y: rand(args.grid.h - 30),  # Posición aleatoria en Y dentro de la pantalla
      speed: 1 + rand(2),         # Velocidad aleatoria (1, 2 o 3)
      color: slime_color,         # Color aleatorio basado en el nombre de la carpeta
      size: 30 + rand(30)         # Tamaño más grande para los slimes
    }
  end
end

def vacuum_slimes(args)
  # Atrae slimes hacia el cursor si el botón izquierdo del mouse está presionado
  cursor_x = args.inputs.mouse.x
  cursor_y = args.inputs.mouse.y
  suction_speed = 3  # Velocidad de succión hacia el cursor

  args.state.slimes.each do |slime|
    # Calcular la distancia en X y Y desde el slime al cursor
    delta_x = cursor_x - slime[:x]
    delta_y = cursor_y - slime[:y]

    # Calcular la distancia total al cursor
    distance = Math.sqrt(delta_x ** 2 + delta_y ** 2)

    # Mover el slime hacia el cursor si está dentro de un rango de succión (por ejemplo, 200 píxeles)
    if distance < 200
      slime[:x] += suction_speed * (delta_x / distance)
      slime[:y] += suction_speed * (delta_y / distance)
    end
  end
end

def collect_slimes(args)
  # Absorber slimes que colisionen con el cursor cuando se mantiene presionado el clic izquierdo
  cursor_x = args.inputs.mouse.x
  cursor_y = args.inputs.mouse.y

  args.state.slimes.reject! do |slime|
    # Verificar si el cursor está sobre el slime
    if (cursor_x >= slime[:x] && cursor_x <= slime[:x] + slime[:size]) &&
       (cursor_y >= slime[:y] && cursor_y <= slime[:y] + slime[:size])
      args.state.slimes_collected += 1  # Incrementar el contador de slimes recolectados

      # Reproducir sonido al recolectar un slime
      args.audio[:sfxcollect] = { input: 'assets/sounds/sfxcollect.wav', finish: :delete }
      true  # Eliminar el slime de la lista
    else
      false  # Mantener el slime en la lista
    end
  end
end

def move_slimes_randomly(args)
  # Mover los slimes en una dirección aleatoria
  args.state.slimes.each do |slime|
    slime[:x] += slime[:speed] * (rand(2) == 0 ? 1 : -1)
    slime[:y] += slime[:speed] * (rand(2) == 0 ? 1 : -1)

    # Asegurarse de que los slimes no se salgan de la pantalla
    slime[:x] = [[slime[:x], 0].max, args.grid.w - slime[:size]].min
    slime[:y] = [[slime[:y], 0].max, args.grid.h - slime[:size]].min
  end
end

def draw_slimes(args)
  # Dibujar cada slime en la pantalla
  args.state.slimes.each do |slime|
    color_name = slime[:color]
    
    # Ruta del archivo de la animación (con un solo archivo GIF para cada slime)
    path = "assets/sprites/slimes/#{color_name}/slime_#{color_name.sub('slime', '')}_front.gif"

    # Incrementamos el contador de animación solo cuando se cumple el ciclo de velocidad
    args.state.animation_counter += 1
    if args.state.animation_counter >= args.state.animation_speed
      args.state.animation_counter = 0  # Reiniciar el contador
    end

    # Usamos el frame solo cuando el contador ha llegado al límite de velocidad
    frame = (args.state.animation_counter * 16 / args.state.animation_speed) % 16  # Ciclo entre los 16 frames

    # Depuración: Imprimir el path y el frame generado
    puts "Loading slime from: #{path}, frame: #{frame}"

    # Mostrar el slime en la pantalla
    args.outputs.sprites << {
      x: slime[:x], y: slime[:y], w: slime[:size], h: slime[:size],
      path: path, frame: frame  # Usamos la variable frame para mostrar la animación
    }
  end
end

def draw_time_left(args)
  # Texto con el tiempo restante

  seconds_left = args.state.time_left
  time_text = "Time Left: #{args.state.time_left}s"
  font_size = 8
  padding = 10  # Margen adicional para que el fondo no esté justo al borde del texto

  # Calcular un tamaño estimado del fondo (esto no es perfecto, pero es una aproximación)
  estimated_width = time_text.length * font_size * 0.6  # Estimación simple para el ancho
  background_width = estimated_width + padding * 2
  background_height = font_size + padding * 2

  # Dibujar el fondo del texto (con color sólido)
  args.outputs.solids << {
    x: 10, y: args.grid.h - 30 - padding,
    w: background_width, h: background_height,
    r: 255, g: 255, b: 255, a: 200  # Color de fondo blanco con algo de transparencia
  }
  # Contorno negro para el texto
  args.outputs.labels << {
    x: 10, y: args.grid.h - 30,
    text: time_text,
    font: args.state.font,
    size_enum: font_size, r: 0, g: 0, b: 0, a: 255,  # Contorno negro
    offset_x: 2, offset_y: -2  # Desplazamiento para el contorno
  }
end







def draw_slimes_collected(args)
  # Mostrar los slimes recolectados con un color más visible

    # Contorno negro para mejorar visibilidad
    args.outputs.labels << {
      x: 10, y: args.grid.h - 70,
      text: "Slimes Collected: #{args.state.slimes_collected}",
      font: args.state.font,
      size_enum: 8, r: 0, g: 0, b: 0, a: 255, # Contorno negro
      offset_x: 2, offset_y: -2  # Desplazamos el contorno
    }
end


def display_game_over(args)
  # Dimensiones del texto para calcular la posición centrada
  game_over_text = "GAME OVER"
  score_text = "Final Score: #{args.state.slimes_collected}"
  restart_text = "Press R to Restart"

  # Calcular posiciones centradas en la pantalla
  text_x = args.grid.w / 2
  game_over_y = args.grid.h / 2 + 30
  score_y = game_over_y - 50
  restart_y = score_y - 50

  # Mostrar el mensaje de Game Over centrado
  args.outputs.labels << {
    x: text_x, y: game_over_y, text: game_over_text,
    alignment_enum: 1, size_enum: 20, r: 255, g: 0, b: 0, font: args.state.font
  }

  # Mostrar el puntaje final debajo del mensaje de Game Over
  args.outputs.labels << {
    x: text_x, y: score_y, text: score_text,
    alignment_enum: 1, size_enum: 10, r: 255, g: 255, b: 255, font: args.state.font
  }

  # Mostrar instrucción para reiniciar el juego
  args.outputs.labels << {
    x: text_x, y: restart_y, text: restart_text,
    alignment_enum: 1, size_enum: 8, r: 200, g: 200, b: 200, font: args.state.font
  }

  # Si el jugador presiona "R", reinicia el juego
  restart_game(args) if args.inputs.keyboard.key_down.r
end

def restart_game(args)
  # Reiniciar el juego
  args.state.clear!
  args.state.last_tick=args.state.tick_count
  args.state.time_left = 20
  args.state.slimes ||= []
  args.state.slimes_collected = 0
  args.state.game_over = false
  args.state.number_of_slimes = 0;
end

def load_font(args)
  # Cargar la fuente si aún no está cargada
  args.state.font ||= "assets/fonts/pixel_font.ttf"
end

def tile_rect(index)
  TILE_SIZE = 32
  # Devuelve el área del tile basado en su índice (0 a 3)
  {
    x: index * TILE_SIZE,
    y: 0,
    w: TILE_SIZE,
    h: TILE_SIZE
  }
end

def draw_background(args)
  # Si el fondo ya ha sido dibujado, solo usamos los datos guardados
  if !args.state.background_drawn
    TILESET = 'assets/sprites/tilegrass.png'
    TILE_SIZE = 32
    cols = (1280 / TILE_SIZE).ceil
    rows = (720 / TILE_SIZE).ceil
    background_data = []

    rows.times do |row|
      cols.times do |col|
        tile_index = rand(4)  # Usamos una variedad de tiles
        tile_rect_coords = tile_rect(tile_index)

        # Guardamos los datos de la posición de cada tile
        background_data << {
          x: col * TILE_SIZE,
          y: row * TILE_SIZE,
          w: TILE_SIZE,
          h: TILE_SIZE,
          path: TILESET,
          source_x: tile_rect_coords[:x],
          source_y: tile_rect_coords[:y],
          source_w: tile_rect_coords[:w],
          source_h: tile_rect_coords[:h]
        }
      end
    end

    # Guardamos la matriz de tiles en el estado para usarla más tarde
    args.state.background_data = background_data
    args.state.background_drawn = true  # Marcamos que el fondo ya fue generado
  end

  # Dibujamos el fondo usando los datos previamente generados
  args.outputs.sprites.concat(args.state.background_data)
end




