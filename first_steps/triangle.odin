package first_steps

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

vertex_shader_source: cstring = `#version 330 core
layout (location = 0) in vec3 aPos;
void main()
{
   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}`

fragment_shader_source: cstring = `#version 330 core
out vec4 FragColor;
void main()
{
   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}`

main :: proc() {
	if !glfw.Init() {
		fmt.println("Failed to initialize GLFW")
		return
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	when ODIN_OS == .Darwin {
		glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, gl.TRUE)
	}

	window := glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", nil, nil)
	assert(window != nil, "Failed to create GLFW window")
	defer glfw.DestroyWindow(window)

	glfw.MakeContextCurrent(window)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback) // sempre que o valor de window for alterado, vai chamar framebuffer_size_callback
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

	vertex := [?]f32{-0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.0, 0.5, 0.0}
	success: i32
	info_log: [512]u8

	VBO: u32
	gl.GenBuffers(1, &VBO) // declaramos um buffer VBO com ID 1
	gl.BindBuffer(gl.ARRAY_BUFFER, VBO) // falamos qual o tipo desse buffer
	// Ao aplicar raw_data(), você descarta temporariamente os metadados de tamanho e segurança, obtendo apenas o endereço de memória do primeiro elemento
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertex), raw_data(&vertex), gl.STATIC_DRAW) // copia os dados do vertex para o buffer(GPU)

	VAO: u32
	gl.GenVertexArrays(1, &VAO)
	gl.BindVertexArray(VAO)
	gl.BindBuffer(gl.ARRAY_BUFFER, VAO)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertex), raw_data(&vertex), gl.STATIC_DRAW)

	vertex_shader: u32
	vertex_shader = gl.CreateShader(gl.VERTEX_SHADER)
	gl.ShaderSource(vertex_shader, 1, &vertex_shader_source, nil)
	gl.CompileShader(vertex_shader)

	fragment_shader: u32
	fragment_shader = gl.CreateShader(gl.FRAGMENT_SHADER)
	gl.ShaderSource(fragment_shader, 1, &fragment_shader_source, nil)
	gl.CompileShader(fragment_shader)

	shader_program: u32
	shader_program = gl.CreateProgram()
	gl.AttachShader(shader_program, vertex_shader)
	gl.AttachShader(shader_program, fragment_shader)
	gl.LinkProgram(shader_program)

	gl.GetProgramiv(shader_program, gl.LINK_STATUS, &success)
	if success == 0 {
		gl.GetProgramInfoLog(shader_program, 512, nil, &info_log[0])
	}

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(u32), 0)
	gl.EnableVertexAttribArray(0)

	gl.DeleteShader(vertex_shader)
	gl.DeleteShader(fragment_shader)

	for !glfw.WindowShouldClose(window) {
		process_input(window)

		gl.ClearColor(0.2, 0.3, 0.1, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		gl.UseProgram(shader_program)
		gl.BindVertexArray(VAO)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}
}
