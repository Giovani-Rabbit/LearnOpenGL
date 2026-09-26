package triangle

import "core:fmt"
import "core:os"
import "core:strings"
import gl "vendor:OpenGL"

Shader :: struct {
	id: u32,
}

shader_init :: proc(vertex_path, fragment_path: string) -> (shader: Shader, ok: bool) {
	vertex_src, v_err := os.read_entire_file(vertex_path, context.allocator)
	if v_err != nil {
		fmt.eprintln("ERROR::SHADER::FILE_NOT_SUCCESFULLY_READ", vertex_path, v_err)
		return {}, false
	}
	defer delete(vertex_src)

	fragment_src, f_err := os.read_entire_file(fragment_path, context.allocator)
	if f_err != nil {
		fmt.eprintln("ERROR::SHADER::FILE_NOT_SUCCESFULLY_READ", fragment_src, f_err)
	}
	defer delete(fragment_src)

	vertex := compile_shader(string(vertex_src), gl.VERTEX_SHADER, "VERTEX") or_return
	defer gl.DeleteShader(vertex)

	fragment := compile_shader(string(fragment_src), gl.FRAGMENT_SHADER, "FRAGMENT") or_return
	defer gl.DeleteShader(fragment)

	program := gl.CreateProgram()
	gl.AttachShader(program, vertex)
	gl.AttachShader(program, fragment)
	gl.LinkProgram(program)

	success: i32
	gl.GetProgramiv(program, gl.LINK_STATUS, &success)

	if success == 0 {
		info_log: [512]u8
		gl.GetProgramInfoLog(program, 512, nil, raw_data(info_log[:]))
		fmt.eprintln("ERROR::SHADER::PROGRAM::LINKING_FAILED\n", string(info_log[:]))
		return {}, false
	}

	return Shader{id = program}, true
}

@(private)
compile_shader :: proc(src: string, shader_type: u32, label: string) -> (u32, bool) {
	shader := gl.CreateShader(shader_type)
	c_src := strings.clone_to_cstring(src)
	defer delete(c_src)

	gl.ShaderSource(shader, 1, &c_src, nil)
	gl.CompileShader(shader)

	success: i32
	gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)

	if success == 0 {
		info_log: [512]u8
		gl.GetShaderInfoLog(shader, 512, nil, raw_data(info_log[:]))
		fmt.eprintln("ERROR::SHADER::", label, "::COMPILATION_FAILED\n", string(info_log[:]))
		return 0, false
	}

	return shader, true
}

shader_use :: proc(shader: Shader) {
	gl.UseProgram(shader.id)
}
