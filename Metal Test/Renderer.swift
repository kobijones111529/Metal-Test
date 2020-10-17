import Foundation
import Metal
import MetalKit
import GLKit

class Renderer: NSObject, MTKViewDelegate {
	
	let device: MTLDevice
	let commandQueue: MTLCommandQueue
	
	var vertexData: [Vertex] = [
		Vertex(position: [-0.5, -0.5, -1.0], color: [1.0, 0.0, 0.0, 1.0]),
		Vertex(position: [-0.5, 0.5, -1.0], color: [0.0, 1.0, 0.0, 1.0]),
		Vertex(position: [0.5, 0.5, -1.0], color: [0.0, 0.0, 1.0, 1.0]),
		
		Vertex(position: [0.5, 0.5, -1.0], color: [0.0, 0.0, 1.0, 1.0]),
		Vertex(position: [0.5, -0.5, -1.0], color: [1.0, 1.0, 0.0, 1.0]),
		Vertex(position: [-0.5, -0.5, -1.0], color: [1.0, 0.0, 0.0, 1.0])
	]
	
	// Uniforms struct must be wrapped in array in order for its data to be copied to the buffer
	var uniforms: [Uniforms] = [Uniforms()]
	
	var camera: PerspectiveCamera
	var modelMatrix: GLKMatrix4 = GLKMatrix4Identity
	
	let vertexBufferSize: Int
	let uniformBufferSize: Int
	let vertexBuffer: MTLBuffer!
	let uniformBuffer: MTLBuffer!
	
	let pipelineState: MTLRenderPipelineState
	
	init?(mtkView: MTKView) {
		device = mtkView.device!
		commandQueue = device.makeCommandQueue()!
		
		camera = PerspectiveCamera(fov: Float.pi / 2, aspectRatio: Float(mtkView.bounds.size.width / mtkView.bounds.size.height), near: 0.001, far: 100.0)
		
		vertexBufferSize = vertexData.count * MemoryLayout<Vertex>.stride
		uniformBufferSize = MemoryLayout<Uniforms>.stride
		vertexBuffer = device.makeBuffer(length: vertexBufferSize, options: [])
		uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: [])
		
		do {
			let pipelineDescriptor = MTLRenderPipelineDescriptor()
			
			let library = device.makeDefaultLibrary()
			pipelineDescriptor.vertexFunction = library?.makeFunction(name: "basic_vertex")
			pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "basic_fragment")
			
			pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
			
			pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
		} catch {
			print("Unable to compile render pipeline state: \(error)")
			return nil
		}
	}
	
	func draw(in view: MTKView) {
		camera.rotateY(radians: 0.005)
		
		uniforms[0].projectionMatrix = Renderer.toSIMD(from: camera.projectionMatrix)
		uniforms[0].viewMatrix = Renderer.toSIMD(from: camera.viewMatrix)
		uniforms[0].modelMatrix = Renderer.toSIMD(from: modelMatrix)
		
		let vertexBufferPointer = vertexBuffer.contents()
		let uniformBufferPointer = uniformBuffer.contents()
		memcpy(vertexBufferPointer, vertexData, vertexBufferSize)
		memcpy(uniformBufferPointer, uniforms, uniformBufferSize)
		
		guard let commandBuffer = commandQueue.makeCommandBuffer() else {
			return
		}
		
		guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
			return
		}
		
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1);
		
		guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
			return
		}
		
		renderEncoder.setRenderPipelineState(pipelineState)
		renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
		renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
		renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count)
		
		renderEncoder.endEncoding()
		
		commandBuffer.present(view.currentDrawable!)
		commandBuffer.commit()
	}
	
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		camera.aspectRatio = Float(size.width / size.height)
	}
	
	private static func toSIMD(from: GLKMatrix4) -> simd_float4x4 {
		var temp = simd_float4x4()
		for i in 0...3 {
			for j in 0...3 {
				temp[i][j] = from[i * 4 + j]
			}
		}
		return temp
	}
	
}
