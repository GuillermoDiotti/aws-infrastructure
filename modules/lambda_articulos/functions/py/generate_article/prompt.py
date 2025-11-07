def master_prompt(topic, style, length, words):
    return f"""Escribe un artículo {style} sobre {topic}.
        El artículo debe tener una longitud {length} (teniendo {words}) cantidad de palabras).

        Estructura requerida:
        - Empieza con un título claro y atractivo (usando # en markdown)
        - Divide el contenido en secciones con subtítulos (usando ##)
        - Usa un tono profesional pero accesible
        - Incluye ejemplos concretos cuando sea relevante

        Genera solo el artículo, sin introducción ni comentarios adicionales."""

