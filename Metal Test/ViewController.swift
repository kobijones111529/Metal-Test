import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController {
	
	var mtkView: MTKView!
	var renderer: Renderer!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set MTKView instance variable
		guard let mtkViewTemp = self.view as? MTKView else {
			print("View attached to ViewControl not an MTKView!")
			return
		}
		mtkView = mtkViewTemp
		
		// Provide device to MTKView
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		print("GPU: \(defaultDevice)")
		mtkView.device = defaultDevice
		
		// Initalize renderer and set as MTKView delegate
		guard let rendererTemp = Renderer(mtkView: mtkView) else {
			print("Failed to initialize Renderer")
			return
		}
		renderer = rendererTemp
		mtkView.delegate = renderer
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

}

