import Foundation
import GLKit

class PerspectiveCamera {
	
	var fov: Float
	var aspectRatio: Float
	var near: Float
	var far: Float
	
	var position: GLKVector3 = GLKVector3()
	var rotation: GLKQuaternion = GLKQuaternionIdentity
	
	var projectionMatrix: GLKMatrix4 {
		get {
			return GLKMatrix4MakePerspective(fov, aspectRatio, near, far)
		}
	}
	
	var viewMatrix: GLKMatrix4 {
		get {
			let inversePosition = GLKVector3Negate(position)
			let inverseRotation = GLKQuaternionInvert(rotation)
			return GLKMatrix4TranslateWithVector3(GLKMatrix4MakeWithQuaternion(inverseRotation), inversePosition)
		}
	}
	
	init(fov: Float, aspectRatio: Float, near: Float, far: Float) {
		self.fov = fov
		self.aspectRatio = aspectRatio
		self.near = near
		self.far = far
	}
	
	init(fov: Float, aspectRatio: Float, near: Float, far: Float, position: GLKVector3, rotation: GLKQuaternion) {
		self.fov = fov
		self.aspectRatio = aspectRatio
		self.near = near
		self.far = far
		self.position = position
		self.rotation = rotation
	}
	
	func translate(x: Float, y: Float, z: Float) {
		let v = GLKVector3(v: (x, y, z))
		position = GLKVector3Add(position, v)
	}
	
	func translate(v: GLKVector3) {
		position = GLKVector3Add(position, v)
	}
	
	func rotate(radians: Float, x: Float, y: Float, z: Float) {
		rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndAxis(radians, x, y, z))
	}
	
	func rotate(radians: Float, axis: GLKVector3) {
		rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndVector3Axis(radians, axis))
	}
	
	func rotate(r: GLKQuaternion) {
		rotation = GLKQuaternionMultiply(rotation, r)
	}
	
	func rotateX(radians: Float) {
		rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndAxis(radians, 1.0, 0.0, 0.0))
	}
	
	func rotateY(radians: Float) {
		rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndAxis(radians, 0.0, 1.0, 0.0))
	}
	
	func rotateZ(radians: Float) {
		rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndAxis(radians, 0.0, 0.0, 1.0))
	}
	
}
