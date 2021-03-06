package arm.ui;

import zui.*;
import zui.Zui.State;
import zui.Canvas;
import iron.data.SceneFormat;
import iron.data.MeshData;
import iron.data.MaterialData;
import iron.object.Object;
import iron.object.MeshObject;
import iron.math.Mat4;
import iron.math.Math;
import iron.RenderPath;
import arm.ProjectFormat;
import arm.ProjectFormat.TAPConfig;
import arm.util.*;

@:access(zui.Zui)
@:access(iron.data.Data)
class UITrait extends iron.Trait {

	public var project:TProjectFormat;
	public var projectPath = "";

	public var bundled:Map<String, kha.Image> = new Map();
	public var assets:Array<TAsset> = [];
	public var assetNames:Array<String> = [];
	public var assetId = 0;

	public static var inst:UITrait;
	public static var defaultWindowW = 280;

	public static var penPressure = true;
	public var undoI = 0; // Undo layer
	public var undos = 0; // Undos available
	public var redos = 0; // Redos available
	public var pushUndo = false; // Store undo on next paint

	public var isScrolling = false;
	public var colorIdPicked = false;
	public var show = true;
	public var materialPreview = false; // Drawing material previews
	public var savedCamera = Mat4.identity();
	public var baseRPicked = 0.0;
	public var baseGPicked = 0.0;
	public var baseBPicked = 0.0;
	public var normalRPicked = 0.0;
	public var normalGPicked = 0.0;
	public var normalBPicked = 0.0;
	public var roughnessPicked = 0.0;
	public var metallicPicked = 0.0;
	public var occlusionPicked = 0.0;
	public var materialIdPicked = 0.0;
	public var pickerSelectMaterial = true;
	public var pickerMaskHandle = new Zui.Handle({position: 0});
	var message = "";
	var messageTimer = 0.0;
	var messageColor = 0x00000000;

	public var savedEnvmap:kha.Image = null;
	public var emptyEnvmap:kha.Image = null;
	public var previewEnvmap:kha.Image = null;
	public var showEnvmap = false;
	public var showEnvmapHandle = new Zui.Handle({selected: false});
	public var showEnvmapBlur = false;
	public var showEnvmapBlurHandle = new Zui.Handle({selected: false});
	public var drawWireframe = false;
	public var wireframeHandle = new Zui.Handle({selected: false});
	public var culling = true;

	public var ddirty = 0;
	public var pdirty = 0;
	public var rdirty = 0;
	public var brushBlendDirty = true;
	public var layerPreviewDirty = true;

	public var windowW = 280; // Panel width
	public var toolbarw = 54;
	public var headerh = 24;
	public var menubarw = 215;

	public var ui:Zui;
	public var systemId = "";
	public var colorIdHandle = Id.handle();

	public var formatType = 0;
	public var formatQuality = 80.0;
	public var outputType = 0;
	public var isBase = true;
	public var isBaseSpace = 0;
	public var isOpac = false;
	public var isOpacSpace = 0;
	public var isOcc = true;
	public var isOccSpace = 0;
	public var isRough = true;
	public var isRoughSpace = 0;
	public var isMet = true;
	public var isMetSpace = 0;
	public var isNor = true;
	public var isNorSpace = 0;
	public var isEmis = false;
	public var isEmisSpace = 0;
	public var isHeight = false;
	public var isHeightSpace = 0;
	public var isSubs = false;
	public var isSubsSpace = 0;
	public var isUdim = false;
	public var hwnd = Id.handle();
	public var hwnd1 = Id.handle();
	public var hwnd2 = Id.handle();
	public var materials:Array<MaterialSlot> = null;
	public var selectedMaterial:MaterialSlot;
	public var materials2:Array<MaterialSlot> = null;
	public var selectedMaterial2:MaterialSlot;
	public var brushes:Array<BrushSlot> = null;
	public var selectedBrush:BrushSlot;
	public var selectedLogic:BrushSlot;
	public var layers:Array<LayerSlot> = null;
	public var undoLayers:Array<LayerSlot> = null;
	public var selectedLayer:LayerSlot;
	public var selectedLayerIsMask = false; // Mask selected for active layer
	var selectTime = 0.0;
	public var displaceStrength = 1.0;
	public var decalImage:kha.Image = null;
	public var decalPreview = false;
	public var viewportMode = 0;
	public var instantMat = true;
	var hscaleWasChanged = false;

	public var textToolImage:kha.Image = null;
	public var textToolText = "Text";
	public var textToolHandle = new Zui.Handle({position: 0});
	public var decalMaskImage:kha.Image = null;
	public var decalMaskHandle = new Zui.Handle({position: 0});
	public var particleMaterial:MaterialData = null;

	var layerFilter = 0;

	var _onBrush:Array<Int->Void> = [];

	public var paintVec = new iron.math.Vec4();
	public var lastPaintX = -1.0;
	public var lastPaintY = -1.0;
	public var painted = 0;
	public var brushTime = 0.0;
	public var cloneStartX = -1.0;
	public var cloneStartY = -1.0;
	public var cloneDeltaX = 0.0;
	public var cloneDeltaY = 0.0;

	public var selectedObject:iron.object.Object;
	public var paintObject:iron.object.MeshObject;
	public var paintObjects:Array<iron.object.MeshObject> = null;
	public var gizmo:iron.object.Object = null;
	var gizmoX:iron.object.Object = null;
	var gizmoY:iron.object.Object = null;
	var gizmoZ:iron.object.Object = null;
	public var grid:iron.object.Object = null;
	public var selectedType = "";
	var axisX = false;
	var axisY = false;
	var axisZ = false;
	var axisStart = 0.0;
	var row4 = [1/4, 1/4, 1/4, 1/4];
	public var pipe:kha.graphics4.PipelineState = null;

	public var brushNodesRadius = 1.0;
	public var brushNodesOpacity = 1.0;
	public var brushNodesScale = 1.0;
	public var brushNodesHardness = 1.0;

	public var brushRadius = 0.5;
	public var brushRadiusHandle = new Zui.Handle({value: 0.5});
	public var brushOpacity = 1.0;
	public var brushScale = 1.0;
	public var brushRot = 0.0;
	public var brushHardness = 0.8;
	public var brushBias = 1.0;
	public var brushPaint = 0;
	public var selectedTool = 0;

	public var bakeStrength = 1.0;
	public var bakeRadius = 1.0;
	public var bakeOffset = 1.0;
	
	public var paintVisible = true;
	public var mirrorX = false;
	public var showGrid = false;
	public var showCompass = true;
	public var autoFillHandle = new Zui.Handle({selected: false});
	public var fillTypeHandle = new Zui.Handle();
	public var resHandle = new Zui.Handle({position: 1}); // 2048
	public var mergedObject:MeshObject = null; // For object mask
	var newConfirm = false;
	public var newObject = 0;
	public var newObjectNames = ["Cube", "Plane", "Sphere", "Cylinder"];

	public var sub = 0;
	public var vec2 = new iron.math.Vec4();

	public var lastPaintVecX = -1.0;
	public var lastPaintVecY = -1.0;
	var frame = 0;
	public var paint2d = false;

	public var C:TAPConfig;
	var altStartedX = -1.0;
	var altStartedY = -1.0;
	var lockStartedX = -1.0;
	var lockStartedY = -1.0;
	var brushLocked = false;
	var brushCanLock = false;
	var brushCanUnlock = false;
	public var cameraType = 0;
	// public var originalShadowBias = 0.0;
	public var camHandle = new Zui.Handle({position: 0});
	public var fovHandle:Zui.Handle = null;
	public var undoHandle:Zui.Handle = null;
	public var hssgi:Zui.Handle = null;
	public var hssr:Zui.Handle = null;
	public var hbloom:Zui.Handle = null;
	public var hsupersample:Zui.Handle = null;
	public var hvxao:Zui.Handle = null;
	var textureExport = false;
	var textureExportPath = "";
	public var projectExport = false;
	public var headerHandle = new Zui.Handle({layout:Horizontal});
	public var toolbarHandle = new Zui.Handle();
	public var statusHandle = new Zui.Handle({layout:Horizontal});
	public var menuHandle = new Zui.Handle({layout:Horizontal});
	public var workspaceHandle = new Zui.Handle({layout:Horizontal});

	public var cameraControls = 1;
	public var htab = Id.handle({position: 0});
	public var htab1 = Id.handle({position: 0});
	public var htab2 = Id.handle({position: 0});
	public var worktab = Id.handle({position: 0});

	function loadBundled(names:Array<String>, done:Void->Void) {
		var loaded = 0;
		for (s in names) {
			iron.data.Data.getImage(s, function(image:kha.Image) {
				bundled.set(s, image);
				loaded++;
				if (loaded == names.length) done();
			});
		}
	}

	public function notifyOnBrush(f:Int->Void) {
		_onBrush.push(f);
	}

	public function dirty():Bool {
		return paintDirty() || depthDirty() || rdirty > 0;
	}

	public function depthDirty():Bool {
		return ddirty > 0;
	}

	public function paintDirty():Bool {
		if (UITrait.inst.worktab.position == 1) return false;
		return pdirty > 0;
	}

	public function new() {
		super();

		inst = this;
		systemId = kha.System.systemId;

		// Init config
		C = cast armory.data.Config.raw;
		if (C.ui_layout == null) C.ui_layout = 0;
		if (C.undo_steps == null) C.undo_steps = 4; // Max steps to keep

		windowW = Std.int(defaultWindowW * C.window_scale);
		toolbarw = Std.int(54 * C.window_scale);
		headerh = Std.int(24 * C.window_scale);
		menubarw = Std.int(215 * C.window_scale);

		Uniforms.init();

		if (materials == null) {
			materials = [];
			//
			iron.data.Data.getMaterial("Scene", "Material", function(m:iron.data.MaterialData) {
				materials.push(new MaterialSlot(m));
				selectedMaterial = materials[0];
			});
			//
			// materials.push(new MaterialSlot());
			// selectedMaterial = materials[0];
		}
		if (materials2 == null) {
			materials2 = [];
			iron.data.Data.getMaterial("Scene", "Material2", function(m:iron.data.MaterialData) {
				materials2.push(new MaterialSlot(m));
				selectedMaterial2 = materials2[0];
			});
		}

		if (brushes == null) {
			brushes = [];
			brushes.push(new BrushSlot());
			selectedBrush = brushes[0];
		}

		if (layers == null) {
			layers = [];
			layers.push(new LayerSlot());
			selectedLayer = layers[0];
		}
		if (undoLayers == null) {
			undoLayers = [];
			for (i in 0...C.undo_steps) undoLayers.push(new LayerSlot("_undo" + undoLayers.length));
		}

		if (savedEnvmap == null) {
			savedEnvmap = iron.Scene.active.world.envmap;
		}
		if (emptyEnvmap == null) {
			// emptyEnvmap = kha.Image.fromBytes(1, 1); // No lock for d3d11
			emptyEnvmap = kha.Image.create(1, 1);
			var b = emptyEnvmap.lock();
			b.set(0, 3);
			b.set(1, 3);
			b.set(2, 3);
			b.set(3, 255);
			emptyEnvmap.unlock();
		}
		if (previewEnvmap == null) {
			var b = haxe.io.Bytes.alloc(4);
			b.set(0, 0);
			b.set(1, 0);
			b.set(2, 0);
			b.set(3, 255);
			previewEnvmap = kha.Image.fromBytes(b, 1, 1);
		}

		// Save last pos for continuos paint
		iron.App.notifyOnRender(function(g:kha.graphics4.Graphics) { //

			if (frame == 0) {
				UINodes.inst.parseMeshMaterial();
				UINodes.inst.parsePaintMaterial();
				RenderUtil.makeMaterialPreview();
			}
			frame++;

			var m = iron.system.Input.getMouse();
			if (m.down()) { //
				UITrait.inst.lastPaintVecX = UITrait.inst.paintVec.x; //
				UITrait.inst.lastPaintVecY = UITrait.inst.paintVec.y; //
			}//
			else {
				UITrait.inst.lastPaintVecX = m.x / iron.App.w();
				UITrait.inst.lastPaintVecY = m.y / iron.App.h();
			}
		});//

		var scale = C.window_scale;
		ui = new Zui( { theme: arm.App.theme, font: arm.App.font, scaleFactor: scale, color_wheel: arm.App.color_wheel } );
		loadBundled([
			'cursor.png',
			'tool_draw.png',
			'tool_eraser.png',
			'tool_fill.png',
			'tool_bake.png',
			'tool_colorid.png',
			'tool_decal.png',
			'tool_text.png',
			'tool_clone.png',
			'tool_blur.png',
			'tool_particle.png',
			'tool_picker.png',
			'drag.png'
		], done);
	}

	public function showMessage(s:String) {
		messageTimer = 8.0;
		message = s;
		messageColor = 0x00000000;
		statusHandle.redraws = 2;
	}

	public function showError(s:String) {
		messageTimer = 8.0;
		message = s;
		messageColor = 0xffff0000;
		statusHandle.redraws = 2;
	}

	function done() {
		//
		// grid = iron.Scene.active.getChild(".Grid");
		gizmo = iron.Scene.active.getChild(".GizmoTranslate");
		gizmo.transform.scale.set(0.5, 0.5, 0.5);
		gizmo.transform.buildMatrix();
		gizmoX = iron.Scene.active.getChild("GizmoX");
		gizmoY = iron.Scene.active.getChild("GizmoY");
		gizmoZ = iron.Scene.active.getChild("GizmoZ");
		//

		selectedObject = iron.Scene.active.getChild("Cube");
		paintObject = cast(selectedObject, MeshObject);
		paintObjects = [paintObject];

		iron.App.notifyOnRender(Layers.initLayers);

		// Init plugins
		Plugin.keep();
		if (C.plugins != null) {
			for (plugin in C.plugins) {
				iron.data.Data.getBlob(plugin, function(blob:kha.Blob) {
					#if js
					untyped __js__("(1, eval)({0})", blob.toString());
					#end
				});
			}
		}
	}

	function update() {
		if (textureExport) {
			textureExport = false;
			Exporter.exportTextures(textureExportPath);
		}
		if (projectExport) {
			projectExport = false;
			Project.exportProject();
		}

		isScrolling = ui.isScrolling;
		updateUI();

		for (p in Plugin.plugins) if (p.update != null) p.update();

		var kb = iron.system.Input.getKeyboard();
		var shift = kb.down("shift");
		var ctrl = kb.down("control");
		var alt = kb.down("alt");
		alt = false; // TODO: gets stuck after alt+tab

		if (!arm.App.uimodal.isTyping) {
			if (kb.started("escape")) {
				arm.App.showFiles = false;
				arm.App.showBox = false;
			}
			if (arm.App.showFiles) {
				if (kb.started("enter")) {
					arm.App.showFiles = false;
					arm.App.filesDone(arm.App.path);
					UITrait.inst.ddirty = 2;
				}
			}
		}

		if (!arm.App.uienabled) return;

		if (kb.started("tab")) {
			if (ctrl) { // Cycle layers
				var i = (layers.indexOf(selectedLayer) + 1) % layers.length;
				setLayer(layers[i]);
			}
			else { // Toggle node editor
				if (!UINodes.inst.ui.isTyping && !UITrait.inst.ui.isTyping) {
					showMaterialNodes();
				}
			}
		}

		if (ctrl && !shift && kb.started("s")) Project.projectSave();
		else if (ctrl && shift && kb.started("s")) Project.projectSaveAs();
		else if (ctrl && kb.started("o")) Project.projectOpen();
		else if (ctrl && kb.started("n")) App.projectNew();
		else if (ctrl && shift && kb.started("e")) { // Export textures
			if (textureExportPath == "") { // First export, ask for path
				arm.App.showFiles = true;
				@:privateAccess zui.Ext.lastPath = "";
				arm.App.whandle.redraws = 2;
				arm.App.foldersOnly = true;
				arm.App.showFilename = true;
				arm.App.filesDone = function(path:String) {
					textureExport = true;
					textureExportPath = path;
				}
			}
			else textureExport = true;
		}
		else if (ctrl && shift && kb.started("i")) { // Import asset
			arm.App.showFiles = true;
			@:privateAccess zui.Ext.lastPath = ""; // Refresh
			arm.App.whandle.redraws = 2;
			arm.App.foldersOnly = false;
			arm.App.showFilename = false;
			arm.App.filesDone = function(path:String) {
				Importer.importFile(path);
			}
		}

		if (kb.started("f11") ||
		   (kb.started("escape") && !show && !arm.App.showFiles && !arm.App.showBox)) {
			show = !show;
			arm.App.resize();
		}

		var mouse = iron.system.Input.getMouse();

		if (brushCanLock || brushLocked) {
			if (kb.down("f") && mouse.moved) {
				if (brushLocked) {
					brushRadius += mouse.movementX / 100;
					brushRadius = Math.max(0.05, Math.min(4.0, brushRadius));
					brushRadius = Math.round(brushRadius * 100) / 100;
					brushRadiusHandle.value = brushRadius;
					headerHandle.redraws = 2;
				}
				else if (brushCanLock) {
					brushCanLock = false;
					brushLocked = true;
				}
			}
		}

		var right = iron.App.w();
		if (UIView2D.inst.show) right = iron.App.w() * 2;

		// Viewport shortcuts
		if (mouse.x > 0 && mouse.x < right &&
			mouse.y > 0 && mouse.y < iron.App.h() &&
			!ui.isTyping && !UIView2D.inst.ui.isTyping && !UINodes.inst.ui.isTyping) {

			if (UITrait.inst.worktab.position == 0) { // Paint
				if (shift) {
					if (kb.started("1")) selectMaterial(0);
					else if (kb.started("2")) selectMaterial(1);
					else if (kb.started("3")) selectMaterial(2);
					else if (kb.started("4")) selectMaterial(3);
					else if (kb.started("5")) selectMaterial(4);
					else if (kb.started("6")) selectMaterial(5);
				}

				if (!ctrl && !mouse.down("right")) {
					if (kb.started("b")) selectTool(ToolBrush);
					else if (kb.started("e")) selectTool(ToolEraser);
					else if (kb.started("g")) selectTool(ToolFill);
					else if (kb.started("k")) selectTool(ToolBake);
					else if (kb.started("c")) selectTool(ToolColorId);
					else if (kb.started("d")) selectTool(ToolDecal);
					else if (kb.started("t")) selectTool(ToolText);
					else if (kb.started("l")) selectTool(ToolClone);
					else if (kb.started("u")) selectTool(ToolBlur);
					else if (kb.started("p")) selectTool(ToolParticle);
					else if (kb.started("v")) selectTool(ToolPicker);
				}

				// Radius
				if (!ctrl && !shift) {
					if (selectedTool == ToolBrush  ||
						selectedTool == ToolEraser ||
						selectedTool == ToolDecal  ||
						selectedTool == ToolText   ||
						selectedTool == ToolClone  ||
						selectedTool == ToolBlur   ||
						selectedTool == ToolParticle) {
						if (kb.started("f")) {
							brushCanLock = true;
							mouse.lock();
							lockStartedX = mouse.x + iron.App.x();
							lockStartedY = mouse.y + iron.App.y();
						}
					}
				}
			}

			// Viewpoint
			if (!shift && !alt) {
				if (kb.started("0")) {
					ViewportUtil.resetViewport();
					ViewportUtil.scaleToBounds();
				}
				else if (kb.started("1")) {
					ctrl ?
						ViewportUtil.setView(0, 1, 0, Math.PI / 2, 0, Math.PI) :
						ViewportUtil.setView(0, -1, 0, Math.PI / 2, 0, 0);
				}
				else if (kb.started("3")) {
					ctrl ?
						ViewportUtil.setView(-1, 0, 0, Math.PI / 2, 0, -Math.PI / 2) :
						ViewportUtil.setView(1, 0, 0, Math.PI / 2, 0, Math.PI / 2);
				}
				else if (kb.started("7")) {
					ctrl ?
						ViewportUtil.setView(0, 0, -1, Math.PI, 0, Math.PI) :
						ViewportUtil.setView(0, 0, 1, 0, 0, 0);
				}
				else if (kb.started("5")) {
					cameraType = cameraType == 0 ? 1 : 0;
					camHandle.position = cameraType;
					updateCameraType(cameraType);
					statusHandle.redraws = 2;
				}
			}
		}

		if (brushCanLock || brushLocked) {
			if (mouse.moved && brushCanUnlock) {
				brushLocked = false;
				brushCanUnlock = false;
			}
			if (kb.released("f")) {
				mouse.unlock();
				brushCanUnlock = true;
			}
		}
	}

	function selectMaterial(i:Int) {
		if (materials.length <= i) return;
		setMaterial(materials[i]);
	}

	public function setMaterial(m:MaterialSlot) {
		selectedMaterial = m;
		autoFillHandle.selected = false; // Auto-disable
		UINodes.inst.updateCanvasMap();
		UINodes.inst.parsePaintMaterial();
		hwnd1.redraws = 2;
		headerHandle.redraws = 2;

		var current = @:privateAccess kha.graphics4.Graphics2.current;
		if (current != null) current.end();
		var decal = selectedTool == ToolDecal || selectedTool == ToolText;
		if (decal) RenderUtil.makeDecalPreview();
		if (current != null) current.begin(false);
	}

	function selectMaterial2(i:Int) {
		if (materials2.length <= i) return;
		selectedMaterial2 = materials2[i];

		if (Std.is(selectedObject, iron.object.MeshObject)) {
			cast(selectedObject, iron.object.MeshObject).materials[0] = selectedMaterial2.data;
		}

		UINodes.inst.updateCanvasMap();
		UINodes.inst.parsePaintMaterial();

		hwnd.redraws = 2;
	}

	function selectBrush(i:Int) {
		if (brushes.length <= i) return;
		selectedBrush = brushes[i];
		UINodes.inst.updateCanvasBrushMap();
		UINodes.inst.parseBrush();
		hwnd1.redraws = 2;
	}

	public function setLayer(l:LayerSlot, isMask = false) {
		selectedLayer = l;
		selectedLayerIsMask = isMask;
		autoFillHandle.selected = false; // Auto-disable
		headerHandle.redraws = 2;

		var current = @:privateAccess kha.graphics4.Graphics2.current;
		if (current != null) current.end();

		setObjectMask();
		UINodes.inst.parseMeshMaterial();
		UINodes.inst.parsePaintMaterial();

		if (current != null) current.begin(false);

		hwnd.redraws = 2;
	}

	public function doUndo() {
		if (undos > 0) {
			undoI = undoI - 1 < 0 ? C.undo_steps - 1 : undoI - 1;
			var lay = undoLayers[undoI];
			var opos = paintObjects.indexOf(lay.targetObject);
			var lpos = layers.indexOf(lay.targetLayer);
			if (opos >= 0 && lpos >= 0) {
				selectPaintObject(paintObjects[opos]);
				setLayer(layers[lpos]);
				selectedLayer.swap(lay);
				layerPreviewDirty = true;
			}
			undos--;
			redos++;
			if (UIView2D.inst.show) UIView2D.inst.hwnd.redraws = 2;
		}
	}

	public function doRedo() {
		if (redos > 0) {
			var lay = undoLayers[undoI];
			var opos = paintObjects.indexOf(lay.targetObject);
			var lpos = layers.indexOf(lay.targetLayer);
			if (opos >= 0 && lpos >= 0) {
				selectPaintObject(paintObjects[opos]);
				setLayer(layers[lpos]);
				selectedLayer.swap(lay);
			}
			undoI = (undoI + 1) % C.undo_steps;
			undos++;
			redos--;
			if (UIView2D.inst.show) UIView2D.inst.hwnd.redraws = 2;
		}
	}

	function updateUI() {

		if (messageTimer > 0) {
			messageTimer -= iron.system.Time.delta;
			if (messageTimer <= 0) statusHandle.redraws = 2;
		}

		var mouse = iron.system.Input.getMouse();
		var kb = iron.system.Input.getKeyboard();

		if (!arm.App.uienabled) return;

		var down = iron.system.Input.getMouse().down() || iron.system.Input.getPen().down();
		if (down && !kb.down("control")) {
			var mx = mouse.x;
			var my = mouse.y;
			if (paint2d) mx -= iron.App.w();

			if (mx < iron.App.w() && mx > iron.App.x() &&
				my < iron.App.h() && my > iron.App.y()) {
				
				if (selectedTool == ToolClone && kb.down("alt")) { // Clone source
					cloneStartX = mx;
					cloneStartY = my;
				}
				else {
					if (brushTime == 0) { // Paint started
						pushUndo = true;
						if (projectPath != "") {
							kha.Window.get(0).title = arm.App.filenameHandle.text + "* - ArmorPaint";
						}
						if (selectedTool == ToolClone && cloneStartX >= 0.0) { // Clone delta
							cloneDeltaX = (cloneStartX - mx) / iron.App.w();
							cloneDeltaY = (cloneStartY - my) / iron.App.h();
							cloneStartX = -1;
						}
						else if (selectedTool == ToolParticle) {
							// Reset particles
							var emitter:iron.object.MeshObject = cast iron.Scene.active.getChild(".ParticleEmitter");
							var psys = emitter.particleSystems[0];
							@:privateAccess psys.time = 0;
							// @:privateAccess psys.time = @:privateAccess psys.seed * @:privateAccess psys.animtime;
							// @:privateAccess psys.seed++;
						}
					}
					brushTime += iron.system.Time.delta;
					for (f in _onBrush) f(0);
				}
			}

		}
		else if (brushTime > 0) { // Brush released
			brushTime = 0;
			ddirty = 3;
			brushBlendDirty = true; // Update brush mask
			layerPreviewDirty = true; // Update layer preview
		}

		if (layerPreviewDirty) {
			layerPreviewDirty = false;
			// Update layer preview
			var l = selectedLayer;
			var target = selectedLayerIsMask ? l.texpaint_mask_preview : l.texpaint_preview;
			var source = selectedLayerIsMask ? l.texpaint_mask : l.texpaint;
			var g2 = target.g2;
			g2.begin(true, 0xff000000);
			g2.drawScaledImage(source, 0, 0, target.width, target.height);
			g2.end();
			hwnd.redraws = 2;
		}

		var undoPressed = kb.down("control") && !kb.down("shift") && kb.started("z");
		if (systemId == 'OSX') undoPressed = !kb.down("shift") && kb.started("z"); // cmd+z on macos

		var redoPressed = (kb.down("control") && kb.down("shift") && kb.started("z")) ||
						   kb.down("control") && kb.started("y");
		if (systemId == 'OSX') redoPressed = (kb.down("shift") && kb.started("z")) || kb.started("y"); // cmd+y on macos

		if (undoPressed) doUndo();
		else if (redoPressed) doRedo();

		if (UITrait.inst.worktab.position == 1) {
			updateGizmo();
		}
	}

	function updateGizmo() {
		if (!gizmo.visible) return;

		if (selectedObject != null) {
			gizmo.transform.loc.setFrom(selectedObject.transform.loc);
			gizmo.transform.buildMatrix();
		}

		var mouse = iron.system.Input.getMouse();
		var kb = iron.system.Input.getKeyboard();

		if (mouse.x < App.w()) {
			if (kb.started("delete") || kb.started("backspace")) {
				if (selectedObject != null) {
					selectedObject.remove();
					selectObject(iron.Scene.active.getChild("Scene"));
				}
			}
			if (kb.started("c") && selectedObject != null) {
				if (Std.is(selectedObject, iron.object.MeshObject)) {
					var mo = cast(selectedObject, iron.object.MeshObject);
					var object = iron.Scene.active.addMeshObject(mo.data, mo.materials, iron.Scene.active.getChild("Scene"));
					object.name = mo.name + '.1';

					object.transform.loc.setFrom(mo.transform.loc);
					object.transform.rot.setFrom(mo.transform.rot);
					object.transform.scale.setFrom(mo.transform.scale);

					var hit = iron.math.RayCaster.planeIntersect(iron.math.Vec4.zAxis(), new iron.math.Vec4(), mouse.x, mouse.y, iron.Scene.active.camera);
					if (hit != null) {
						object.transform.loc.x = hit.x;
						object.transform.loc.y = hit.y;
						object.transform.setRotation(0, 0, Math.random() * 3.1516 * 2);
					}

					object.transform.buildMatrix();

					#if arm_physics
					object.addTrait(new armory.trait.physics.RigidBody(0, 0));
					#end

					selectObject(object);
				}
				else if (Std.is(selectedObject, iron.object.LightObject)) {
					var lo = cast(selectedObject, iron.object.LightObject);
					var object = iron.Scene.active.addLightObject(lo.data, iron.Scene.active.getChild("Scene"));
					object.name = lo.name + '.1';

					object.transform.loc.setFrom(lo.transform.loc);
					object.transform.rot.setFrom(lo.transform.rot);
					object.transform.scale.setFrom(lo.transform.scale);
					object.transform.buildMatrix();

					#if arm_physics
					object.addTrait(new armory.trait.physics.RigidBody(0, 0));
					#end

					selectObject(object);
				}
			}
			if (kb.started("m")) { // skip voxel
				selectedMaterial2.data.raw.skip_context = selectedMaterial2.data.raw.skip_context == '' ? 'voxel' : '';
			}
		}

		if (mouse.started("middle")) {
			#if arm_physics
			var physics = armory.trait.physics.PhysicsWorld.active;
			var rb = physics.pickClosest(mouse.x, mouse.y);
			if (rb != null) selectObject(rb.object);
			#end
		}

		if (mouse.started("left") && selectedObject.name != "Scene") {
			gizmo.transform.buildMatrix();
			var trs = [gizmoX.transform, gizmoY.transform, gizmoZ.transform];
			var hit = iron.math.RayCaster.closestBoxIntersect(trs, mouse.x, mouse.y, iron.Scene.active.camera);
			if (hit != null) {
				if (hit.object == gizmoX) axisX = true;
				else if (hit.object == gizmoY) axisY = true;
				else if (hit.object == gizmoZ) axisZ = true;
				if (axisX || axisY || axisZ) axisStart = 0.0;
			}
		}
		else if (mouse.released("left")) {
			axisX = axisY = axisZ = false;
		}

		if (axisX || axisY || axisZ) {
			var t = selectedObject.transform;
			var v = new iron.math.Vec4();
			v.set(t.worldx(), t.worldy(), t.worldz());
			
			if (axisX) {
				var hit = iron.math.RayCaster.planeIntersect(iron.math.Vec4.yAxis(), v, mouse.x, mouse.y, iron.Scene.active.camera);
				if (hit != null) {
					if (axisStart == 0) axisStart = hit.x - selectedObject.transform.loc.x;
					selectedObject.transform.loc.x = hit.x - axisStart;
					selectedObject.transform.buildMatrix();
					#if arm_physics
					var rb = selectedObject.getTrait(armory.trait.physics.RigidBody);
					if (rb != null) rb.syncTransform();
					#end
				}
			}
			else if (axisY) {
				var hit = iron.math.RayCaster.planeIntersect(iron.math.Vec4.xAxis(), v, mouse.x, mouse.y, iron.Scene.active.camera);
				if (hit != null) {
					if (axisStart == 0) axisStart = hit.y - selectedObject.transform.loc.y;
					selectedObject.transform.loc.y = hit.y - axisStart;
					selectedObject.transform.buildMatrix();
					#if arm_physics
					var rb = selectedObject.getTrait(armory.trait.physics.RigidBody);
					if (rb != null) rb.syncTransform();
					#end
				}
			}
			else if (axisZ) {
				var hit = iron.math.RayCaster.planeIntersect(iron.math.Vec4.xAxis(), v, mouse.x, mouse.y, iron.Scene.active.camera);
				if (hit != null) {
					if (axisStart == 0) axisStart = hit.z - selectedObject.transform.loc.z;
					selectedObject.transform.loc.z = hit.z - axisStart;
					selectedObject.transform.buildMatrix();
					#if arm_physics
					var rb = selectedObject.getTrait(armory.trait.physics.RigidBody);
					if (rb != null) rb.syncTransform();
					#end
				}
			}
		}

		iron.system.Input.occupied = (axisX || axisY || axisZ) && mouse.x < App.w();
	}

	function render(g:kha.graphics2.Graphics) {
		if (kha.System.windowWidth() == 0 || kha.System.windowHeight() == 0) return;

		renderUI(g);

		// var ready = showFiles || dirty;
		// TODO: Texture params get overwritten
		// if (ready) for (t in UINodes.inst._matcon.bind_textures) t.params_set = null;
		// if (UINodes.inst._matcon != null) for (t in UINodes.inst._matcon.bind_textures) t.params_set = null;
	}

	function renderCursor(g:kha.graphics2.Graphics) {
		// if (cursorImg == null) {
		// 	g.end();
		// 	cursorImg = kha.Image.createRenderTarget(256, 256);
		// 	cursorImg.g2.begin(true, 0x00000000);
		// 	cursorImg.g2.color = 0xffcccccc;
		// 	kha.graphics2.GraphicsExtension.drawCircle(cursorImg.g2, 128, 128, 124, 8);
		// 	cursorImg.g2.end();
		// 	g.begin(false);
		// }

		g.color = 0xffffffff;

		// Brush
		if (arm.App.uienabled && worktab.position == 0) {
			var cursorImg = bundled.get('cursor.png');
			var mouse = iron.system.Input.getMouse();
			var mx = mouse.x + iron.App.x();
			var my = mouse.y + iron.App.y();
			var pen = iron.system.Input.getPen();
			if (pen.down()) {
				mx = pen.x + iron.App.x();
				my = pen.y + iron.App.y();
			}

			// Radius being scaled
			if (brushLocked) {
				mx += lockStartedX - kha.System.windowWidth() / 2;
				my += lockStartedY - kha.System.windowHeight() / 2;
			}

			var psize = Std.int(cursorImg.width * (brushRadius * brushNodesRadius));

			var decal = selectedTool == ToolDecal || selectedTool == ToolText;
			if (decal) {
				psize = Std.int(256 * (brushRadius * brushNodesRadius));
				#if kha_direct3d11
				g.drawScaledImage(decalImage, mx - psize / 2, my - psize / 2, psize, psize);
				#else
				g.drawScaledImage(decalImage, mx - psize / 2, my - psize / 2 + psize, psize, -psize);
				#end
			}
			else {
				if (selectedTool == ToolBrush  ||
					selectedTool == ToolEraser ||
					selectedTool == ToolClone  ||
					selectedTool == ToolBlur   ||
					selectedTool == ToolParticle) {
					g.drawScaledImage(cursorImg, mx - psize / 2, my - psize / 2, psize, psize);
				}
			}

			if (mirrorX) {
				var cx = iron.App.x() + iron.App.w() / 2;
				var nx = cx + (cx - mx);
				// Separator line
				g.color = 0x66ffffff;
				g.fillRect(cx - 1, 0, 2, iron.App.h());
				if (decal) {
					#if kha_direct3d11
					g.drawScaledImage(decalImage, nx - psize / 2, my - psize / 2, psize, psize);
					#else
					g.drawScaledImage(decalImage, nx - psize / 2, my - psize / 2 + psize, psize, -psize);
					#end
				}
				else { // Cursor
					g.drawScaledImage(cursorImg, nx - psize / 2, my - psize / 2, psize, psize);
				}
				g.color = 0xffffffff;
			}

			var kb = iron.system.Input.getKeyboard();
			if (selectedTool == ToolClone && !kb.down("alt") && (mouse.down() || pen.down())) { // Clone source cursor
				g.color = 0x66ffffff;
				g.drawScaledImage(cursorImg, mx + cloneDeltaX * iron.App.w() - psize / 2, my + cloneDeltaY * iron.App.h() - psize / 2, psize, psize);
				g.color = 0xffffffff;
			}

			if (showGrid) {
				// Separator line
				var x1 = iron.App.x() + iron.App.w() / 3;
				var x2 = iron.App.x() + iron.App.w() / 3 * 2;
				var y1 = iron.App.y() + iron.App.h() / 3;
				var y2 = iron.App.y() + iron.App.h() / 3 * 2;
				g.color = 0x66ffffff;
				g.fillRect(x1 - 1, iron.App.y(), 2, iron.App.h());
				g.fillRect(x2 - 1, iron.App.y(), 2, iron.App.h());
				g.fillRect(iron.App.x(), y1 - 1, iron.App.x() + iron.App.w(), 2);
				g.fillRect(iron.App.x(), y2 - 1, iron.App.x() + iron.App.w(), 2);
				g.color = 0xffffffff;
			}
		}
	}

	function showMaterialNodes() {
		// Clear input state as ui receives input events even when not drawn
		@:privateAccess UINodes.inst.ui.endInput();

		if (UINodes.inst.show && UINodes.inst.canvasType == 0) UINodes.inst.show = false;
		else { UINodes.inst.show = true; UINodes.inst.canvasType = 0; }
		arm.App.resize();
	}

	function showBrushNodes() {
		// Clear input state as ui receives input events even when not drawn
		@:privateAccess UINodes.inst.ui.endInput();

		if (UINodes.inst.show && UINodes.inst.canvasType == 1) UINodes.inst.show = false;
		else { UINodes.inst.show = true; UINodes.inst.canvasType = 1; }
		arm.App.resize();
	}

	// function showLogicNodes() {
	//	// Clear input state as ui receives input events even when not drawn
	//	@:privateAccess UINodes.inst.ui.endInput();

	// 	if (UINodes.inst.show && UINodes.inst.canvasType == 2) UINodes.inst.show = false;
	// 	else { UINodes.inst.show = true; UINodes.inst.canvasType = 2; }
	// 	arm.App.resize();
	// }

	// function showParticleNodes() {}

	function show2DView() {
		// Clear input state as ui receives input events even when not drawn
		@:privateAccess UIView2D.inst.ui.endInput();

		UIView2D.inst.show = !UIView2D.inst.show;
		arm.App.resize();
	}

	function selectTool(i:Int) {
		selectedTool = i;
		autoFillHandle.selected = false; // Auto-disable
		UINodes.inst.parsePaintMaterial();
		UINodes.inst.parseMeshMaterial();
		headerHandle.redraws = 2;
		toolbarHandle.redraws = 2;

		var decal = selectedTool == ToolDecal || selectedTool == ToolText;
		if (decal) {
			var current = @:privateAccess kha.graphics4.Graphics2.current;
			if (current != null) current.end();

			if (selectedTool == ToolDecal) {
				RenderUtil.makeDecalMaskPreview();
			}
			else if (selectedTool == ToolText) {
				RenderUtil.makeTextPreview();
			}

			RenderUtil.makeDecalPreview();
			
			if (current != null) current.begin(false);
		}

		if (selectedTool == ToolParticle) {
			initParticle();
			UINodes.inst.parseParticleMaterial();
		}
	}

	public function selectObject(o:iron.object.Object) {
		selectedObject = o;

		if (UITrait.inst.worktab.position == 1) {
			if (Std.is(o, iron.object.MeshObject)) {
				for (i in 0...materials2.length) {
					if (materials2[i].data == cast(o, iron.object.MeshObject).materials[0]) {
						// selectMaterial(i); // loop
						selectedMaterial2 = materials2[i];
						hwnd.redraws = 2;
						break;
					}
				}
			}
		}
	}

	public function selectPaintObject(o:iron.object.MeshObject) {
		autoFillHandle.selected = false; // Auto-disable
		headerHandle.redraws = 2;
		for (p in paintObjects) p.skip_context = "paint";
		paintObject = o;

		var mask = selectedLayer.objectMask;
		if (layerFilter > 0) mask = layerFilter;
		
		if (mergedObject == null || mask > 0) {
			paintObject.skip_context = "";
		}
		UIView2D.inst.uvmapCached = false;
		UIView2D.inst.trianglemapCached = false;
	}

	public function getImage(asset:TAsset):kha.Image {
		return Canvas.assetMap.get(asset.id);
	}

	public function mainObject():MeshObject {
		for (po in paintObjects) if (po.children.length > 0) return po;
		return paintObjects[0];
	}

	// var cursorImg:kha.Image = null;

	function renderUI(g:kha.graphics2.Graphics) {
		
		if (!arm.App.uienabled && ui.inputRegistered) ui.unregisterInput();
		if (arm.App.uienabled && !ui.inputRegistered) ui.registerInput();

		if (!show) return;

		g.end();
		ui.begin(g);

		// ui.t.FILL_WINDOW_BG = false;
		var panelx = (iron.App.x() - toolbarw);
		if (C.ui_layout == 1 && (UINodes.inst.show || UIView2D.inst.show)) panelx = panelx - App.w() - toolbarw;
		if (ui.window(toolbarHandle, panelx, headerh, toolbarw, kha.System.windowHeight())) {
			ui._y += 2;

			ui.imageScrollAlign = false;

			if (UITrait.inst.worktab.position == 0) {
				var imgBrush = bundled.get("tool_draw.png");
				var imgEraser = bundled.get("tool_eraser.png");
				var imgFill = bundled.get("tool_fill.png");
				var imgBake = bundled.get("tool_bake.png");
				var imgColorId = bundled.get("tool_colorid.png");
				var imgDecal = bundled.get("tool_decal.png");
				var imgText = bundled.get("tool_text.png");
				var imgClone = bundled.get("tool_clone.png");
				var imgBlur = bundled.get("tool_blur.png");
				var imgParticle = bundled.get("tool_particle.png");
				var imgPicker = bundled.get("tool_picker.png");
				
				ui._x += 2;
				if (selectedTool == ToolBrush) ui.rect(-1, -1, imgBrush.width + 2, imgBrush.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgBrush) == State.Started) selectTool(ToolBrush);
				if (ui.isHovered) ui.tooltip("Brush (B)");
				ui._x -= 2;
				ui._y += 2;
				
				ui._x += 2;
				if (selectedTool == ToolEraser) ui.rect(-1, -1, imgEraser.width + 2, imgEraser.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgEraser) == State.Started) selectTool(ToolEraser);
				if (ui.isHovered) ui.tooltip("Eraser (E)");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (selectedTool == ToolFill) ui.rect(-1, -1, imgFill.width + 2, imgFill.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgFill) == State.Started) selectTool(ToolFill);
				if (ui.isHovered) ui.tooltip("Fill (G)");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (selectedTool == ToolDecal) ui.rect(-1, -1, imgDecal.width + 2, imgDecal.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgDecal) == State.Started) selectTool(ToolDecal);
				if (ui.isHovered) ui.tooltip("Decal (D)");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (selectedTool == ToolText) ui.rect(-1, -1, imgText.width + 2, imgText.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgText) == State.Started) selectTool(ToolText);
				if (ui.isHovered) ui.tooltip("Text (T)");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (selectedTool == ToolClone) ui.rect(-1, -1, imgClone.width + 2, imgClone.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgClone) == State.Started) selectTool(ToolClone);
				if (ui.isHovered) ui.tooltip("Clone (L) - Hold ALT to set source");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (selectedTool == ToolBlur) ui.rect(-1, -1, imgBlur.width + 2, imgBlur.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgBlur) == State.Started) selectTool(ToolBlur);
				if (ui.isHovered) ui.tooltip("Blur (U)");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (selectedTool == ToolParticle) ui.rect(-1, -1, imgParticle.width + 2, imgParticle.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgParticle) == State.Started) selectTool(ToolParticle);
				if (ui.isHovered) ui.tooltip("Particle (P)");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (selectedTool == ToolBake) ui.rect(-1, -1, imgBake.width + 2, imgBake.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgBake) == State.Started) selectTool(ToolBake);
				if (ui.isHovered) ui.tooltip("Bake (K)");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (selectedTool == ToolColorId) ui.rect(-1, -1, imgColorId.width + 2, imgColorId.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgColorId) == State.Started) selectTool(ToolColorId);
				if (ui.isHovered) ui.tooltip("Color ID (C)");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (selectedTool == ToolPicker) ui.rect(-1, -1, imgPicker.width + 2, imgPicker.height + 2, ui.t.HIGHLIGHT_COL, 2);
				if (ui.image(imgPicker) == State.Started) selectTool(ToolPicker);
				if (ui.isHovered) ui.tooltip("Picker (V)");
				ui._x -= 2;
				ui._y += 2;
			}
			else if (UITrait.inst.worktab.position == 1) {
				
				loadBundled(["tool_gizmo.png"], function() {

					var imgGizmo = bundled.get("tool_gizmo.png");
					
					ui._x += 2;
					if (selectedTool == ToolGizmo) ui.rect(-1, -1, imgGizmo.width + 2, imgGizmo.height + 2, ui.t.HIGHLIGHT_COL, 2);
					if (ui.image(imgGizmo) == State.Started) selectTool(ToolGizmo);
					if (ui.isHovered) ui.tooltip("Gizmo (G)");
					ui._x -= 2;
					ui._y += 2;
				});
			}

			ui.imageScrollAlign = true;
		}
		// ui.t.FILL_WINDOW_BG = true;

		var panelx = iron.App.x() - toolbarw;
		if (C.ui_layout == 1 && (UINodes.inst.show || UIView2D.inst.show)) panelx = panelx - App.w() - toolbarw;
		
		var WINDOW_BG_COL = ui.t.WINDOW_BG_COL;
		ui.t.WINDOW_BG_COL = ui.t.SEPARATOR_COL;
		if (ui.window(menuHandle, panelx, 0, menubarw, Std.int((ui.t.ELEMENT_H + 2) * ui.SCALE))) {
			var _w = ui._w;
			ui._w = Std.int(ui._w * 0.5);
			ui._x += 1; // Prevent "File" button highlight on startup
			
			var ELEMENT_OFFSET = ui.t.ELEMENT_OFFSET;
			ui.t.ELEMENT_OFFSET = 0;
			var BUTTON_COL = ui.t.BUTTON_COL;
			ui.t.BUTTON_COL = ui.t.SEPARATOR_COL;

			if (ui.button("File", Left) || (arm.App.showMenu && ui.isHovered)) { arm.App.showMenu = true; arm.App.menuCategory = 0; };
			if (ui.button("Edit", Left) || (arm.App.showMenu && ui.isHovered)) { arm.App.showMenu = true; arm.App.menuCategory = 1; };
			if (ui.button("View", Left) || (arm.App.showMenu && ui.isHovered)) { arm.App.showMenu = true; arm.App.menuCategory = 2; };
			if (ui.button("Help", Left) || (arm.App.showMenu && ui.isHovered)) { arm.App.showMenu = true; arm.App.menuCategory = 3; };
			
			ui._w = _w;
			ui.t.ELEMENT_OFFSET = ELEMENT_OFFSET;
			ui.t.BUTTON_COL = BUTTON_COL;
		}
		ui.t.WINDOW_BG_COL = WINDOW_BG_COL;

		var panelx = (iron.App.x() - toolbarw) + menubarw;
		if (C.ui_layout == 1 && (UINodes.inst.show || UIView2D.inst.show)) panelx = panelx - App.w() - toolbarw;
		if (ui.window(workspaceHandle, panelx, 0, kha.System.windowWidth() - windowW - menubarw, Std.int((ui.t.ELEMENT_H + 2) * ui.SCALE))) {
			ui.tab(worktab, "Paint");
			ui.tab(worktab, "Scene");
			ui.tab(worktab, "Material");
			if (worktab.changed) {
				ddirty = 2;
				toolbarHandle.redraws = 2;
				headerHandle.redraws = 2;
				if (worktab.position == 1) {
					selectTool(ToolGizmo);
				}
				
				if (worktab.position == 2) {
					UINodes.inst.parseMeshPreviewMaterial();
					mainObject().skip_context = "paint";
				}
				else {
					UINodes.inst.parseMeshMaterial();
					mainObject().skip_context = null;
				}
			}
		}

		var panelx = iron.App.x();
		if (C.ui_layout == 1 && (UINodes.inst.show || UIView2D.inst.show)) panelx = panelx - App.w() - toolbarw;
		if (ui.window(headerHandle, panelx, headerh, kha.System.windowWidth() - toolbarw - windowW, Std.int((ui.t.ELEMENT_H + 2) * ui.SCALE))) {

			if (UITrait.inst.worktab.position == 0) {

				if (selectedTool == ToolColorId) {
					ui.text("Picked Color");
					if (colorIdPicked) {
						ui.image(iron.RenderPath.active.renderTargets.get("texpaint_colorid").image, 0xffffffff, 64);
					}
					if (ui.button("Clear")) colorIdPicked = false;
					ui.text("Color ID Map");
					var cid = ui.combo(colorIdHandle, App.getEnumTexts(), "Color ID");
					if (UITrait.inst.assets.length > 0) ui.image(UITrait.inst.getImage(UITrait.inst.assets[cid]));
				}
				else if (selectedTool == ToolPicker) {
					baseRPicked = Math.round(baseRPicked * 10) / 10;
					baseGPicked = Math.round(baseGPicked * 10) / 10;
					baseBPicked = Math.round(baseBPicked * 10) / 10;
					normalRPicked = Math.round(normalRPicked * 10) / 10;
					normalGPicked = Math.round(normalGPicked * 10) / 10;
					normalBPicked = Math.round(normalBPicked * 10) / 10;
					occlusionPicked = Math.round(occlusionPicked * 100) / 100;
					roughnessPicked = Math.round(roughnessPicked * 100) / 100;
					metallicPicked = Math.round(metallicPicked * 100) / 100;
					ui.text('Base $baseRPicked,$baseGPicked,$baseBPicked');
					ui.text('Nor $normalRPicked,$normalGPicked,$normalBPicked');
					ui.text('Occlusion $occlusionPicked');
					ui.text('Roughness $roughnessPicked');
					ui.text('Metallic $metallicPicked');
					pickerSelectMaterial = ui.check(Id.handle({selected: pickerSelectMaterial}), "Select Material");
					ui.combo(pickerMaskHandle, ["None", "Material"], "Mask", true);
					if (pickerMaskHandle.changed) {
						UINodes.inst.updateCanvasMap();
						UINodes.inst.parsePaintMaterial();
					}
				}
				else if (selectedTool == ToolBake) {
					ui.combo(Id.handle(), ["AO"], "Bake");
					var h = Id.handle({value: bakeStrength});
					bakeStrength = ui.slider(h, "Strength", 0.0, 2.0, true);
					if (h.changed) UINodes.inst.parsePaintMaterial();
					var h = Id.handle({value: bakeRadius});
					bakeRadius = ui.slider(h, "Radius", 0.0, 2.0, true);
					if (h.changed) UINodes.inst.parsePaintMaterial();
					var h = Id.handle({value: bakeOffset});
					bakeOffset = ui.slider(h, "Offset", 0.0, 2.0, true);
					if (h.changed) UINodes.inst.parsePaintMaterial();
					ui.check(autoFillHandle, "Auto-Fill");
					if (autoFillHandle.changed) {
						UINodes.inst.updateCanvasMap();
						UINodes.inst.parsePaintMaterial();
						pushUndo = true;
					}
				}
				else {
					if (selectedTool != ToolFill) {
						brushRadius = ui.slider(brushRadiusHandle, "Radius", 0.0, 2.0, true);
					}
					
					if (selectedTool == ToolBrush  ||
						selectedTool == ToolFill   ||
						selectedTool == ToolDecal  ||
						selectedTool == ToolText) {
						var brushScaleHandle = Id.handle({value: brushScale});
						brushScale = ui.slider(brushScaleHandle, "UV Scale", 0.0, 2.0, true);
						if (brushScaleHandle.changed) {
							if (selectedTool == ToolDecal || selectedTool == ToolText) {
								ui.g.end();
								RenderUtil.makeDecalMaskPreview();
								RenderUtil.makeDecalPreview();
								ui.g.begin(false);
							}
							if (autoFillHandle.selected) {
								UINodes.inst.parsePaintMaterial();
							}
						}

						var brushRotHandle = Id.handle({value: brushRot});
						brushRot = ui.slider(brushRotHandle, "UV Rotate", 0.0, 360.0, true, 1);
						// if (brushRotHandle.changed && autoFillHandle.selected) UINodes.inst.parsePaintMaterial();
						if (brushRotHandle.changed) UINodes.inst.parsePaintMaterial();
					}
					
					brushOpacity = ui.slider(Id.handle({value: brushOpacity}), "Opacity", 0.0, 1.0, true);
					
					if (selectedTool == ToolBrush || selectedTool == ToolEraser) {
						brushHardness = ui.slider(Id.handle({value: brushHardness}), "Hardness", 0.0, 1.0, true);
					}
					if (selectedTool == ToolBrush || selectedTool == ToolEraser || selectedTool == ToolFill || selectedTool == ToolClone || selectedTool == ToolBlur) {
						brushBias = ui.slider(Id.handle({value: brushBias}), "Bias", 0.0, 1.0, true);
					}

					ui.combo(Id.handle(), ["Add"], "Blending");

					if (selectedTool == ToolBrush || selectedTool == ToolFill) {
						var paintHandle = Id.handle();
						brushPaint = ui.combo(paintHandle, ["UV Map", "Project"], "TexCoord");
						if (paintHandle.changed) {
							UINodes.inst.parsePaintMaterial();
						}
					}

					if (selectedTool == ToolFill) {
						ui.combo(fillTypeHandle, ["Object", "Face"], "Fill Mode");
						if (fillTypeHandle.changed) {
							if (fillTypeHandle.position == 1) {
								ui.g.end();
								// UIView2D.inst.cacheUVMap();
								UIView2D.inst.cacheTriangleMap();
								ui.g.begin(false);
								// wireframeHandle.selected = drawWireframe = true;
							}
							UINodes.inst.parsePaintMaterial();
							UINodes.inst.parseMeshMaterial();
						}
						ui.check(autoFillHandle, "Auto-Fill");
						if (autoFillHandle.changed) {
							UINodes.inst.updateCanvasMap();
							UINodes.inst.parsePaintMaterial();
							pushUndo = true;
						}
					}
					else {
						paintVisible = ui.check(Id.handle({selected: paintVisible}), "Visible Only");

						if (selectedTool == ToolBrush || selectedTool == ToolEraser || selectedTool == ToolFill || selectedTool == ToolDecal || selectedTool == ToolText) {
							var mirrorHandle = Id.handle({selected: mirrorX});
							mirrorX = ui.check(mirrorHandle, "Mirror");
							if (mirrorHandle.changed) {
								UINodes.inst.updateCanvasMap();
								UINodes.inst.parsePaintMaterial();
							}
						}
					}
					if (selectedTool == ToolDecal) {
						ui.combo(decalMaskHandle, ["Rectangle", "Circle", "Triangle"], "Mask");
						if (decalMaskHandle.changed) {
							ui.g.end();
							RenderUtil.makeDecalMaskPreview();
							RenderUtil.makeDecalPreview();
							ui.g.begin(false);
						}
					}
					if (selectedTool == ToolText) {
						ui.combo(textToolHandle, Importer.fontList, "Font");
						var h = Id.handle();
						h.text = textToolText;
						textToolText = ui.textInput(h, "");
						if (h.changed || textToolHandle.changed) {
							ui.g.end();
							RenderUtil.makeTextPreview();
							RenderUtil.makeDecalPreview();
							ui.g.begin(false);
						}
					}
				}
			}
			else if (UITrait.inst.worktab.position == 1) {
				// ui.button("Clone");
			}
		}

		if (ui.window(statusHandle, iron.App.x(), kha.System.windowHeight() - headerh, kha.System.windowWidth() - toolbarw - windowW, headerh)) {

			var scene = iron.Scene.active;
			var cam = scene.cameras[0];
			cameraControls = ui.combo(Id.handle({position: cameraControls}), ["Rotate", "Orbit", "Fly"], "Controls");
			cameraType = ui.combo(camHandle, ["Perspective", "Orthographic"], "Type");
			if (ui.isHovered) ui.tooltip("Camera Type (5)");
			if (camHandle.changed) {
				updateCameraType(cameraType);
			}

			fovHandle = Id.handle({value: Std.int(cam.data.raw.fov * 100) / 100});
			cam.data.raw.fov = ui.slider(fovHandle, "FoV", 0.3, 2.0, true);
			if (fovHandle.changed) {
				cam.buildProjection();
				ddirty = 2;
			}

			if (messageTimer > 0) {
				var _w = ui._w;
				ui._w = Std.int(ui.ops.font.width(ui.fontSize, message) + 50 * ui.SCALE);
				ui.fill(0, 0, ui._w, ui._h, messageColor);
				ui.text(message);
				ui._w = _w;
			}
		}
		
		var wx = C.ui_layout == 0 ? kha.System.windowWidth() - windowW : 0;
		var wh = Std.int(kha.System.windowHeight() / 3);

		gizmo.visible = false;
		// grid.visible = false;
		if (UITrait.inst.worktab.position == 1) { //

			gizmo.visible = true;
			// grid.visible = true;

			if (ui.window(hwnd, wx, 0, windowW, wh * 3)) {
				if (ui.tab(htab, "Tools")) {
					if (ui.panel(Id.handle({selected: true}), "Outliner", 1)) {
						ui.indent();
						
						var i = 0;
						function drawList(h:zui.Zui.Handle, o:iron.object.Object) {
							if (o.name.charAt(0) == '.') return; // Hidden
							var b = false;
							if (selectedObject == o) {
								ui.fill(0, 0, ui._windowW, ui.t.ELEMENT_H, ui.t.HIGHLIGHT_COL);
							}
							if (o.children.length > 0) {
								b = ui.panel(h.nest(i, {selected: true}), o.name, 0, true);
							}
							else {
								ui._x += 18; // Sign offset
								ui.text(o.name);
								ui._x -= 18;
							}
							if (ui.isReleased) {
								selectObject(o);
								ddirty = 2;
							}
							i++;
							if (b) {
								for (c in o.children) {
									ui.indent();
									drawList(h, c);
									ui.unindent();
								}
							}
						}
						for (c in iron.Scene.active.root.children) {
							drawList(Id.handle(), c);
						}

						ui.unindent();
					}
					
					if (selectedObject == null) selectedType = "";

					ui.separator();
					if (ui.panel(Id.handle({selected: true}), 'Properties $selectedType', 1)) {
						ui.indent();
						
						if (selectedObject != null) {

							var h = Id.handle();
							h.selected = selectedObject.visible;
							selectedObject.visible = ui.check(h, "Visible");
							if (h.changed) ddirty = 2;

							var loc = selectedObject.transform.loc;
							var scale = selectedObject.transform.scale;
							var rot = selectedObject.transform.rot.getEuler();
							rot.mult(180 / 3.141592);
							var f = 0.0;

							ui.row(row4);
							ui.text("Location");

							h = Id.handle();
							h.text = Math.roundfp(loc.x) + "";
							f = Std.parseFloat(ui.textInput(h, "X"));
							if (h.changed) { loc.x = f; ddirty = 2; }

							h = Id.handle();
							h.text = Math.roundfp(loc.y) + "";
							f = Std.parseFloat(ui.textInput(h, "Y"));
							if (h.changed) { loc.y = f; ddirty = 2; }

							h = Id.handle();
							h.text = Math.roundfp(loc.z) + "";
							f = Std.parseFloat(ui.textInput(h, "Z"));
							if (h.changed) { loc.z = f; ddirty = 2; }

							ui.row(row4);
							ui.text("Rotation");
							
							h = Id.handle();
							h.text = Math.roundfp(rot.x) + "";
							f = Std.parseFloat(ui.textInput(h, "X"));
							var changed = false;
							if (h.changed) { changed = true; rot.x = f; ddirty = 2; }

							h = Id.handle();
							h.text = Math.roundfp(rot.y) + "";
							f = Std.parseFloat(ui.textInput(h, "Y"));
							if (h.changed) { changed = true; rot.y = f; ddirty = 2; }

							h = Id.handle();
							h.text = Math.roundfp(rot.z) + "";
							f = Std.parseFloat(ui.textInput(h, "Z"));
							if (h.changed) { changed = true; rot.z = f; ddirty = 2; }

							if (changed && selectedObject.name != "Scene") {
								rot.mult(3.141592 / 180);
								selectedObject.transform.rot.fromEuler(rot.x, rot.y, rot.z);
								selectedObject.transform.buildMatrix();
								#if arm_physics
								var rb = selectedObject.getTrait(armory.trait.physics.RigidBody);
								if (rb != null) rb.syncTransform();
								#end
							}

							ui.row(row4);
							ui.text("Scale");
							
							h = Id.handle();
							h.text = Math.roundfp(scale.x) + "";
							f = Std.parseFloat(ui.textInput(h, "X"));
							if (h.changed) { scale.x = f; ddirty = 2; }

							h = Id.handle();
							h.text = Math.roundfp(scale.y) + "";
							f = Std.parseFloat(ui.textInput(h, "Y"));
							if (h.changed) { scale.y = f; ddirty = 2; }

							h = Id.handle();
							h.text = Math.roundfp(scale.z) + "";
							f = Std.parseFloat(ui.textInput(h, "Z"));
							if (h.changed) { scale.z = f; ddirty = 2; }

							selectedObject.transform.dirty = true;

							if (selectedObject.name == "Scene") {
								selectedType = "(Scene)";
								// ui.image(envThumb);
								var p = iron.Scene.active.world.probe;
								// ui.row([1/2, 1/2]);
								// var envType = ui.combo(Id.handle({position: 0}), ["Outdoor"], "Map");
								var envHandle = Id.handle({value: p.raw.strength});
								p.raw.strength = ui.slider(envHandle, "Strength", 0.0, 5.0, true);
								if (envHandle.changed) {
									ddirty = 2;
								}
							}
							else if (Std.is(selectedObject, iron.object.LightObject)) {
								selectedType = "(Light)";
								var light = cast(selectedObject, iron.object.LightObject);
								var lhandle = Id.handle();
								lhandle.value = light.data.raw.strength / 1333;
								lhandle.value = Std.int(lhandle.value * 100) / 100;
								light.data.raw.strength = ui.slider(lhandle, "Strength", 0.0, 4.0, true) * 1333;
								if (lhandle.changed) {
									ddirty = 2;
								}
							}
							else if (Std.is(selectedObject, iron.object.CameraObject)) {
								selectedType = "(Camera)";
								var scene = iron.Scene.active;
								var cam = scene.cameras[0];
								var fovHandle = Id.handle({value: Std.int(cam.data.raw.fov * 100) / 100});
								cam.data.raw.fov = ui.slider(fovHandle, "FoV", 0.3, 2.0, true);
								if (fovHandle.changed) {
									cam.buildProjection();
									ddirty = 2;
								}
							}
							else {
								selectedType = "(Object)";
								
							}
						}

						// if (ui.button("LNodes")) showLogicNodes();

						ui.unindent();
					}

					// ui.separator();
					// if (ui.panel(Id.handle({selected: true}), "Materials", 1)) {

					// 	for (row in 0...Std.int(Math.ceil(materials2.length / 5))) { 
					// 		ui.row([1/5,1/5,1/5,1/5,1/5]);

					// 		if (row > 0) ui._y += 6;

					// 		#if (kha_opengl || kha_webgl)
					// 		ui.imageInvertY = true; // Material preview
					// 		#end

					// 		for (j in 0...5) {
					// 			var i = j + row * 5;
					//			if (i >= materials2.length) {
					// 				@:privateAccess ui.endElement();
					//				continue;
					//			}
					// 			var img = materials2[i].image;

					// 			if (selectedMaterial2 == materials2[i]) {
					// 				// ui.fill(1, -2, img.width + 3, img.height + 3, ui.t.HIGHLIGHT_COL); // TODO
					// 				var off = row % 2 == 1 ? 1 : 0;
					// 				var w = 51 - C.window_scale;
					// 				ui.fill(1,          -2, w + 3,       2, ui.t.HIGHLIGHT_COL);
					// 				ui.fill(1,     w - off, w + 3, 2 + off, ui.t.HIGHLIGHT_COL);
					// 				ui.fill(1,          -2,     2,   w + 3, ui.t.HIGHLIGHT_COL);
					// 				ui.fill(w + 3,      -2,     2,   w + 4, ui.t.HIGHLIGHT_COL);
					// 			}

					// 			if (ui.image(img) == State.Started) {
					// 				if (selectedMaterial2 != materials2[i]) selectMaterial2(i);
					// 				if (iron.system.Time.time() - selectTime < 0.3) showMaterialNodes();
					// 				selectTime = iron.system.Time.time();
					// 			}
					// 			if (ui.isHovered) ui.tooltipImage(img);
					// 		}

					// 		#if (kha_opengl || kha_webgl)
					// 		ui.imageInvertY = false; // Material preview
					// 		#end
					// 	}

					// 	ui.row([1/2,1/2]);
					// 	if (ui.button("New")) {

					// 		iron.data.Data.cachedMaterials.remove("SceneMaterial2");
					// 		iron.data.Data.cachedShaders.remove("Material2_data");
					// 		iron.data.Data.cachedSceneRaws.remove("Material2_data");
					// 		// iron.data.Data.cachedBlobs.remove("Material2_data.arm");
					// 		iron.data.Data.getMaterial("Scene", "Material2", function(md:iron.data.MaterialData) {
					// 			md.name = "Material2." + materials2.length;
					// 			ui.g.end();
					// 			var m = new MaterialSlot(md);
					// 			materials2.push(m);
					// 			selectMaterial2(materials2.length - 1);
					// 			RenderUtil.makeMaterialPreview();
					// 			ui.g.begin(false);
					// 		});
					// 	}
					// 	if (ui.button("Nodes")) {
					// 		showMaterialNodes();
					// 	}
					// }
				}
			}
			ui.end();
			g.begin(false);
			return;
		} // worktab


		if (ui.window(hwnd, wx, 0, windowW, wh)) {
			
			if (ui.tab(htab, "Layers")) {

				ui.row([1/4,1/4,1/2]);
				if (ui.button("New")) {

					// App.showContextMenu(function(ui:Zui) {
					// 	ui.fill(0, 0, ui._w, ui.t.ELEMENT_H * 5, ui.t.SEPARATOR_COL);
					// 	ui.text("Type", Right);
					// 	if (ui.button("Paint Layer", Left)) {
							
					// 	}
					// 	if (ui.button("Fill Layer", Left)) {
							
					// 	}
					// 	if (ui.button("Black Mask", Left)) {
							
					// 	}
					// 	if (ui.button("White Mask", Left)) {
							
					// 	}
					// });

					var l = new LayerSlot();
					layers.push(l);
					setLayer(l);
					iron.App.notifyOnRender(Layers.clearLastLayer);
					layerPreviewDirty = true;
				}

				if (ui.button("2D View")) show2DView();
				
				var ar = ["All"];
				for (p in paintObjects) ar.push(p.name);
				var filterHandle = Id.handle();
				layerFilter = ui.combo(filterHandle, ar, "Filter");
				if (filterHandle.changed) {
					for (p in paintObjects) {
						p.visible = layerFilter == 0 || p.name == ar[layerFilter];
						setObjectMask();
					}
					ddirty = 2;
				}

				function drawList(l:LayerSlot, i:Int) {

					if (layerFilter > 0 &&
						l.objectMask > 0 &&
						l.objectMask != layerFilter) return;

					var h = Id.handle().nest(l.id, {selected: l.visible});
					var layerPanel = h.nest(0, {selected: false});
					var off = ui.t.ELEMENT_OFFSET;
					var step = ui.t.ELEMENT_H;
					var checkw = (ui._windowW / 100 * 8) / ui.SCALE;

					if (layerPanel.selected) {
						ui.fill(checkw, step * 2, (ui._windowW / ui.SCALE - 2) - checkw, step + off, ui.t.SEPARATOR_COL);
					}

					if (selectedLayer == l) {
						if (selectedLayerIsMask) {
							ui.rect(ui._windowW / 100 * 24 - 2, 0, ui._windowW / 100 * 16, step * 2, ui.t.HIGHLIGHT_COL, 2);
						}
						else {
							ui.fill(checkw, 0, (ui._windowW / ui.SCALE - 2) - checkw, step * 2, ui.t.HIGHLIGHT_COL);
						}
					}

					if (l.texpaint_mask != null) {
						ui.row([8/100, 16/100, 16/100, 20/100, 30/100, 10/100]);
					}
					else {
						ui.row([8/100, 16/100, 36/100, 30/100, 10/100]);
					}
					
					var center = (step / 2) * ui.SCALE;
					ui._y += center;
					l.visible = ui.check(h, "");
					if (h.changed) {
						UINodes.inst.parseMeshMaterial();
					}
					ui._y -= center;

					var contextMenu = false;

					ui._y += 3;
					var state = ui.image(l.texpaint_preview);
					ui._y -= 3;
					if (ui.isHovered) {
						ui.tooltipImage(l.texpaint_preview);
					}
					if (ui.isHovered && ui.inputReleasedR) {
						contextMenu = true;
					}
					if (ui.isReleased) {
						setLayer(l);
					}
					if (state == State.Started) {
						if (iron.system.Time.time() - selectTime < 0.25) show2DView();
						selectTime = iron.system.Time.time();
					}

					if (l.texpaint_mask != null) {
						ui._y += 3;
						var state = ui.image(l.texpaint_mask_preview);
						ui._y -= 3;
						if (ui.isHovered) {
							ui.tooltipImage(l.texpaint_mask_preview);
						}
						if (ui.isHovered && ui.inputReleasedR) {
							App.showContextMenu(function(ui:Zui) {
								ui.fill(0, 0, ui._w, ui.t.ELEMENT_H * 3, ui.t.SEPARATOR_COL);
								ui.text(l.name + " Mask", Right);
								if (ui.button("Delete", Left)) {
									l.deleteMask();
									setLayer(l);
								}
								if (ui.button("Apply", Left)) {
									setLayer(l);
								}
							});
						}
						if (ui.isReleased) {
							setLayer(l, true);
						}
					}

					ui._y += center;
					ui.text(l.name);
					ui._y -= center;

					if (ui.isReleased) {
						setLayer(l);
					}

					if (ui.isHovered && ui.inputReleasedR) {
						contextMenu = true;
					}

					if (contextMenu) {
						App.showContextMenu(function(ui:Zui) {
							if (l == layers[0]) {
								ui.fill(0, 0, ui._w, ui.t.ELEMENT_H * 9, ui.t.SEPARATOR_COL);
								ui.text(l.name, Right);
							}
							else {
								ui.fill(0, 0, ui._w, ui.t.ELEMENT_H * 14, ui.t.SEPARATOR_COL);
								ui.text(l.name, Right);
								if (ui.button("Delete", Left) && l != layers[0]) {
									selectedLayer = l;
									Layers.deleteSelectedLayer();
								}
								if (ui.button("Move Up", Left) && l != layers[0]) {
									if (i < layers.length - 1) {
										setLayer(l);
										var t = layers[i + 1];
										layers[i + 1] = layers[i];
										layers[i] = t;
										hwnd.redraws = 2;
									}
								}
								if (ui.button("Move Down", Left) && l != layers[0]) {
									if (i > 1) {
										setLayer(l);
										var t = layers[i - 1];
										layers[i - 1] = layers[i];
										layers[i] = t;
										hwnd.redraws = 2;
									}
								}
								if (ui.button("Merge Down", Left) && l != layers[0]) {
									setLayer(l);
									iron.App.notifyOnRender(Layers.applySelectedLayer);
								}
								if (ui.button("Duplicate", Left) && l != layers[0]) {
									setLayer(l);
									
								}
								if (ui.button("Black Mask", Left) && l != layers[0]) {
									l.createMask(0x00000000);
									setLayer(l, true);
									layerPreviewDirty = true;
								}
								if (ui.button("White Mask", Left) && l != layers[0]) {
									l.createMask(0xffffffff);
									setLayer(l, true);
									layerPreviewDirty = true;
								}
							}

							var baseHandle = Id.handle().nest(l.id, {selected: l.paintBase});
							l.paintBase = ui.check(baseHandle, "Base Color");
							if (baseHandle.changed) {
								UINodes.inst.parseMeshMaterial();
							}
							var norHandle = Id.handle().nest(l.id, {selected: l.paintNor});
							l.paintNor = ui.check(norHandle, "Normal");
							if (norHandle.changed) {
								UINodes.inst.parseMeshMaterial();
							}
							var occHandle = Id.handle().nest(l.id, {selected: l.paintOcc});
							l.paintOcc = ui.check(occHandle, "Occlusion");
							if (occHandle.changed) {
								UINodes.inst.parseMeshMaterial();
							}
							var roughHandle = Id.handle().nest(l.id, {selected: l.paintRough});
							l.paintRough = ui.check(roughHandle, "Roughness");
							if (roughHandle.changed) {
								UINodes.inst.parseMeshMaterial();
							}
							var metHandle = Id.handle().nest(l.id, {selected: l.paintMet});
							l.paintMet = ui.check(metHandle, "Metallic");
							if (metHandle.changed) {
								UINodes.inst.parseMeshMaterial();
							}
							var heightHandle = Id.handle().nest(l.id, {selected: l.paintHeight});
							l.paintHeight = ui.check(heightHandle, "Height");
							if (heightHandle.changed) {
								UINodes.inst.parseMeshMaterial();
							}
							var emisHandle = Id.handle().nest(l.id, {selected: l.paintEmis});
							l.paintEmis = ui.check(emisHandle, "Emission");
							if (emisHandle.changed) {
								UINodes.inst.parseMeshMaterial();
							}
							var subsHandle = Id.handle().nest(l.id, {selected: l.paintSubs});
							l.paintSubs = ui.check(subsHandle, "Subsurface");
							if (subsHandle.changed) {
								UINodes.inst.parseMeshMaterial();
							}
						});
					}

					if (i == 0) {
						@:privateAccess ui.endElement();
					}
					else {
						var blend = ui.combo(Id.handle(), ["Add"], "Blending");
					}

					ui._y += center;
					var showPanel = ui.panel(layerPanel, "", 0, true);
					ui._y -= center;

					if (i == 0) {
						ui._y -= ui.t.ELEMENT_OFFSET;
						@:privateAccess ui.endElement();
					}
					else {
						ui._y -= ui.t.ELEMENT_OFFSET;
						ui.row([8/100, 16/100, 36/100, 30/100, 10/100]);
						@:privateAccess ui.endElement();
						@:privateAccess ui.endElement();
						@:privateAccess ui.endElement();

						var ar = ["Shared"];
						for (p in paintObjects) ar.push(p.name);
						var h = Id.handle().nest(l.id);
						l.objectMask = ui.combo(h, ar, "Object");
						if (h.changed) {
							setLayer(l);
						}
						@:privateAccess ui.endElement();
					}
					ui._y -= ui.t.ELEMENT_OFFSET;

					if (showPanel) {
						ui.row([8/100,92/100]);
						@:privateAccess ui.endElement();
						var opacHandle = Id.handle().nest(l.id, {value: l.maskOpacity});
						l.maskOpacity = ui.slider(opacHandle, "Opacity", 0.0, 1.0, true);
						if (opacHandle.changed) {
							UINodes.inst.parseMeshMaterial();
						}
					}
				}

				for (i in 0...layers.length) {
					if (i >= layers.length) break; // Layer was deleted
					var j = layers.length - 1 - i;
					var l = layers[j];
					drawList(l, j);
				}
			}

			if (ui.tab(htab, "History")) {
			}

			if (ui.tab(htab, "Plugins")) {
				// Draw plugins
				for (p in Plugin.plugins) if (p.drawUI != null) p.drawUI(ui);
			}

			if (ui.tab(htab, "Preferences")) {
				
				if (ui.panel(Id.handle({selected: true}), "Interface", 1)) {
					var hscale = Id.handle({value: C.window_scale});
					ui.slider(hscale, "UI Scale", 0.5, 4.0, true);
					if (!hscale.changed && hscaleWasChanged) {
						if (hscale.value == null || Math.isNaN(hscale.value)) hscale.value = 1.0;
						C.window_scale = hscale.value;
						ui.setScale(hscale.value);
						arm.App.uimodal.setScale(hscale.value);
						UINodes.inst.ui.setScale(hscale.value);
						UIView2D.inst.ui.setScale(hscale.value);
						windowW = Std.int(defaultWindowW * C.window_scale);
						toolbarw = Std.int(54 * C.window_scale);
						headerh = Std.int(24 * C.window_scale);
						menubarw = Std.int(215 * C.window_scale);
						arm.App.resize();
						armory.data.Config.save();
					}
					hscaleWasChanged = hscale.changed;
					ui.row([1/2, 1/2]);
					var layHandle = Id.handle({position: C.ui_layout});
					C.ui_layout = ui.combo(layHandle, ["Right", "Left"], "Layout", true);
					if (layHandle.changed) {
						arm.App.resize();
						armory.data.Config.save();
					}
					var themeHandle = Id.handle({position: 0});
					var themes = ["Dark", "Light"];
					ui.combo(themeHandle, themes, "Theme", true);
					if (themeHandle.changed) {
						iron.data.Data.getBlob("theme_" + themes[themeHandle.position].toLowerCase() + ".arm", function(b:kha.Blob) {
							arm.App.parseTheme(b);
							ui.t = arm.App.theme;
							// UINodes.inst.applyTheme();
							headerHandle.redraws = 2;
							toolbarHandle.redraws = 2;
							statusHandle.redraws = 2;
							workspaceHandle.redraws = 2;
							menuHandle.redraws = 2;
						});
					}
				}

				ui.separator();
				if (ui.panel(Id.handle({selected: true}), "Usage", 1)) {
					undoHandle = Id.handle({value: C.undo_steps});
					C.undo_steps = Std.int(ui.slider(undoHandle, "Undo Steps", 1, 64, false, 1));
					if (undoHandle.changed) {
						ui.g.end();
						while (undoLayers.length < C.undo_steps) undoLayers.push(new LayerSlot("_undo" + undoLayers.length));
						while (undoLayers.length > C.undo_steps) { var l = undoLayers.pop(); l.unload(); }
						undos = 0;
						redos = 0;
						undoI = 0;
						ui.g.begin(false);
						armory.data.Config.save();
					}
					// ui.row([1/2, 1/2]);
					penPressure = ui.check(Id.handle({selected: penPressure}), "Pen Pressure");
					// instantMat = ui.check(Id.handle({selected: instantMat}), "Material Preview");
				}

				#if arm_debug
				iron.Scene.active.sceneParent.getTrait(armory.trait.internal.DebugConsole).visible = ui.check(Id.handle({selected: false}), "Debug Console");
				#end

				hssgi = Id.handle({selected: C.rp_ssgi});
				hssr = Id.handle({selected: C.rp_ssr});
				hbloom = Id.handle({selected: C.rp_bloom});
				hsupersample = Id.handle({position: Config.getSuperSampleQuality(C.rp_supersample)});
				hvxao = Id.handle({selected: C.rp_gi});
				ui.separator();
				if (ui.panel(Id.handle({selected: false}), "Viewport Quality", 1)) {
					ui.row([1/2, 1/2]);
					var vsyncHandle = Id.handle({selected: C.window_vsync});
					C.window_vsync = ui.check(vsyncHandle, "VSync");
					if (vsyncHandle.changed) armory.data.Config.save();
					ui.combo(hsupersample, ["1.0x", "1.5x", "2.0x", "4.0x"], "Super Sample", true);
					if (hsupersample.changed) Config.applyConfig();
					ui.row([1/2, 1/2]);
					ui.check(hvxao, "Voxel AO");
					if (ui.isHovered) ui.tooltip("Cone-traced AO and shadows");
					if (hvxao.changed) Config.applyConfig();
					ui.check(hssgi, "SSAO");
					if (hssgi.changed) Config.applyConfig();
					ui.row([1/2, 1/2]);
					ui.check(hbloom, "Bloom");
					if (hbloom.changed) Config.applyConfig();
					ui.check(hssr, "SSR");
					if (hssr.changed) Config.applyConfig();
					var cullHandle = Id.handle({selected: culling});
					culling = ui.check(cullHandle, "Cull Backfaces");
					if (cullHandle.changed) {
						UINodes.inst.parseMeshMaterial();
					}
				}

				ui.separator();
				if (ui.panel(Id.handle({selected: false}), "Controls", 1)) {
					ui.text("Select Material - Shift+1-9");
					ui.text("Cycle Layers - Ctrl+Tab");
					ui.text("Brush Radius - Hold F+Drag");
					ui.text("Brush Ruler - Hold Shift+Paint");
				}

				// ui.separator();
				// ui.button("Restore Defaults");
				// ui.button("Confirm");
			}
		}

		if (ui.window(hwnd1, wx, wh, windowW, wh)) {

			selectedObject = paintObject;

			if (ui.tab(htab1, "Materials")) {

				ui.row([1/4,1/4]);
				if (ui.button("New")) {
					ui.g.end();
					autoFillHandle.selected = false; // Auto-disable
					headerHandle.redraws = 2;
					selectedMaterial = new MaterialSlot();
					materials.push(selectedMaterial);
					UINodes.inst.updateCanvasMap();
					UINodes.inst.parsePaintMaterial();
					RenderUtil.makeMaterialPreview();
					var decal = selectedTool == ToolDecal || selectedTool == ToolText;
					if (decal) RenderUtil.makeDecalPreview();
					ui.g.begin(false);
				}

				if (ui.button("Nodes")) {
					showMaterialNodes();
				}
				else if (ui.isHovered) ui.tooltip("Show Editor (TAB)");

				for (row in 0...Std.int(Math.ceil(materials.length / 5))) { 
					ui.row([1/5,1/5,1/5,1/5,1/5]);

					if (row > 0) ui._y += 6;

					#if (kha_opengl || kha_webgl)
					ui.imageInvertY = true; // Material preview
					#end

					for (j in 0...5) {
						var i = j + row * 5;
						if (i >= materials.length) {
							@:privateAccess ui.endElement();
							continue;
						}
						var img = materials[i].image;

						if (selectedMaterial == materials[i]) {
							// ui.fill(1, -2, img.width + 3, img.height + 3, ui.t.HIGHLIGHT_COL); // TODO
							var off = row % 2 == 1 ? 1 : 0;
							var w = 51 - C.window_scale;
							ui.fill(1,          -2, w + 3,       2, ui.t.HIGHLIGHT_COL);
							ui.fill(1,     w - off, w + 3, 2 + off, ui.t.HIGHLIGHT_COL);
							ui.fill(1,          -2,     2,   w + 3, ui.t.HIGHLIGHT_COL);
							ui.fill(w + 3,      -2,     2,   w + 4, ui.t.HIGHLIGHT_COL);
						}

						var state = ui.image(img);
						if (state == State.Started) {
							if (selectedMaterial != materials[i]) selectMaterial(i);
							if (iron.system.Time.time() - selectTime < 0.25) showMaterialNodes();
							selectTime = iron.system.Time.time();
						}
						if (ui.isHovered && ui.inputReleasedR) {
							App.showContextMenu(function(ui:Zui) {
								ui.fill(0, 0, ui._w, ui.t.ELEMENT_H * 10, ui.t.SEPARATOR_COL);
								ui.text(UINodes.inst.canvasMap.get(materials[i]).name, Right);
								if (ui.button("Delete", Left) && materials.length > 1) {
									materials.splice(i, 1);
									hwnd1.redraws = 2;
								}
								
								var m = materials[i];
								var baseHandle = Id.handle().nest(m.id, {selected: m.paintBase});
								m.paintBase = ui.check(baseHandle, "Base Color");
								if (baseHandle.changed) {
									UINodes.inst.updateCanvasMap();
									UINodes.inst.parsePaintMaterial();
								}
								var norHandle = Id.handle().nest(m.id, {selected: m.paintNor});
								m.paintNor = ui.check(norHandle, "Normal");
								if (norHandle.changed) {
									UINodes.inst.updateCanvasMap();
									UINodes.inst.parsePaintMaterial();
								}
								var occHandle = Id.handle().nest(m.id, {selected: m.paintOcc});
								m.paintOcc = ui.check(occHandle, "Occlusion");
								if (occHandle.changed) {
									UINodes.inst.updateCanvasMap();
									UINodes.inst.parsePaintMaterial();
								}
								var roughHandle = Id.handle().nest(m.id, {selected: m.paintRough});
								m.paintRough = ui.check(roughHandle, "Roughness");
								if (roughHandle.changed) {
									UINodes.inst.updateCanvasMap();
									UINodes.inst.parsePaintMaterial();
								}
								var metHandle = Id.handle().nest(m.id, {selected: m.paintMet});
								m.paintMet = ui.check(metHandle, "Metallic");
								if (metHandle.changed) {
									UINodes.inst.updateCanvasMap();
									UINodes.inst.parsePaintMaterial();
								}
								var heightHandle = Id.handle().nest(m.id, {selected: m.paintHeight});
								m.paintHeight = ui.check(heightHandle, "Height");
								if (heightHandle.changed) {
									UINodes.inst.updateCanvasMap();
									UINodes.inst.parsePaintMaterial();
								}
								var emisHandle = Id.handle().nest(m.id, {selected: m.paintEmis});
								m.paintEmis = ui.check(emisHandle, "Emission");
								if (emisHandle.changed) {
									UINodes.inst.updateCanvasMap();
									UINodes.inst.parsePaintMaterial();
								}
								var subsHandle = Id.handle().nest(m.id, {selected: m.paintSubs});
								m.paintSubs = ui.check(subsHandle, "Subsurface");
								if (subsHandle.changed) {
									UINodes.inst.updateCanvasMap();
									UINodes.inst.parsePaintMaterial();
								}
							});
						}
						if (ui.isHovered) ui.tooltipImage(img);
					}

					ui._y += 6;

					#if (kha_opengl || kha_webgl)
					ui.imageInvertY = false; // Material preview
					#end
				}

				
			}

			if (ui.tab(htab1, "Brushes")) {
				// var imgBrush = bundled.get("tool_draw.png");
				// ui.imageScrollAlign = false;
				// ui.image(imgBrush);
				// ui.imageScrollAlign = false;
				ui.row([1/4,1/4]);
				if (ui.button("New")) {}
				if (ui.button("Nodes")) showBrushNodes();
			}

			if (ui.tab(htab1, "Particles")) {
				ui.row([1/4,1/4]);
				if (ui.button("New")) {}
				if (ui.button("Nodes")) {}
			}
		}

		if (ui.window(hwnd2, wx, wh * 2, windowW, wh)) {
			if (ui.tab(htab2, "Textures")) {

				ui.row([1/4]);

				if (ui.button("Import")) {
					arm.App.showFiles = true;
					@:privateAccess zui.Ext.lastPath = ""; // Refresh
					arm.App.whandle.redraws = 2;
					arm.App.foldersOnly = false;
					arm.App.showFilename = false;
					arm.App.filesDone = function(path:String) {
						Importer.importFile(path);
					}
				}
				if (ui.isHovered) ui.tooltip("Import texture file (Ctrl + Shift + I)");

				if (assets.length > 0) {
					for (i in 0...assets.length) {
						
						// Align into 5 items per row
						if (i % 5 == 0) {
							ui._y += ui.ELEMENT_OFFSET() * 1.5;
							ui.row([1/5, 1/5, 1/5, 1/5, 1/5]);
						}
						
						var asset = assets[i];
						var img = UITrait.inst.getImage(asset);
						if (ui.image(img) == State.Started) {
							arm.App.dragAsset = asset;
						}

						if (ui.isHovered) ui.tooltipImage(img, 256);

						if (ui.isHovered && ui.inputReleasedR) {
							App.showContextMenu(function(ui:Zui) {
								ui.fill(0, 0, ui._w, ui.t.ELEMENT_H * 2, ui.t.SEPARATOR_COL);
								ui.text(asset.name, Right);
								if (ui.button("Delete", Left)) {
									hwnd2.redraws = 2;
									iron.data.Data.deleteImage(asset.file);
									Canvas.assetMap.remove(asset.id);
									assets.splice(i, 1);
									assetNames.splice(i, 1);
								}
							});
						}
					}

					// Fill in unused row space
					if (assets.length % 5 > 0) {
						for (i in 0...5 - (assets.length % 5)) {
							@:privateAccess ui.endElement();
						}
					}
				}
				else {
					var dragImg = bundled.get('drag.png');
					ui.image(dragImg, ui.t.BUTTON_COL);
					if (ui.isHovered) ui.tooltip("Drag and drop files here");
				}
			}

			if (ui.tab(htab2, "Meshes")) {
				ui.row([1/4]);

				if (ui.button("Import")) {
					arm.App.showFiles = true;
					@:privateAccess zui.Ext.lastPath = ""; // Refresh
					arm.App.whandle.redraws = 2;
					arm.App.foldersOnly = false;
					arm.App.showFilename = false;
					arm.App.filesDone = function(path:String) {
						Importer.importFile(path);
					}
				}
				if (ui.isHovered) ui.tooltip("Import mesh file (Ctrl + Shift + I)");

				isUdim = ui.check(Id.handle({selected: isUdim}), "UDIM import");
				if (ui.isHovered) ui.tooltip("Split mesh per UDIM tile");

				if (ui.panel(Id.handle({selected: false}), "Scene", 0, true)) {
					var i = 0;
					function drawList(h:zui.Zui.Handle, o:iron.object.MeshObject) {
						// if (paintObject == o) {
							// ui.fill(0, 0, ui._windowW, ui.t.ELEMENT_H, 0xff205d9c);
						// }
						// ui.row([1/10, 9/10]);
						// var h = Id.handle().nest(i, {selected: o.visible});
						// o.visible = ui.check(h, "");
						// if (h.changed) ddirty = 2;
						ui.text(o.name);
						// if (ui.isReleased) {
						// 	selectPaintObject(o);
						// }
						i++;
					}
					ui.indent();
					for (c in paintObjects) {
						drawList(Id.handle(), c);
					}
					ui.unindent();
				}

				ui.row([1/2,1/2]);
				if (ui.button("Flip Normals")) {
					MeshUtil.flipNormals();
					ddirty = 2;
				}
				if (ui.button("Calculate Normals")) {
					MeshUtil.calcNormals();
					ddirty = 2;
				}

				ui.row([1/2, 1/2]);
				var upHandle = Id.handle();
				var lastUp = upHandle.position;
				// TODO: Turn into axis rotation instead
				var axisUp = ui.combo(upHandle, ["Z", "-Z", "Y", "-Y"], "Up Axis", true);
				if (upHandle.changed && axisUp != lastUp) {
					MeshUtil.switchUpAxis(axisUp);
					ddirty = 2;
				}
				
				var dispHandle = Id.handle({value: displaceStrength});
				displaceStrength = ui.slider(dispHandle, "Displace", 0.0, 2.0, true);
				if (dispHandle.changed) {
					UINodes.inst.parseMeshMaterial();
				}
			}

			if (ui.tab(htab2, "Export")) {

				if (ui.panel(Id.handle({selected: false}), "Project Quality", 1)) {
					ui.combo(resHandle, ["1K", "2K", "4K", "8K", "16K"], "Res", true);
					if (resHandle.changed) {
						iron.App.notifyOnRender(Layers.resizeLayers);
						UIView2D.inst.uvmap = null;
						UIView2D.inst.uvmapCached = false;
						UIView2D.inst.trianglemap = null;
						UIView2D.inst.trianglemapCached = false;
					}
					ui.combo(Id.handle(), ["8bit"], "Color", true);
				}

				ui.separator();
				if (ui.panel(Id.handle({selected: false}), "Export Mesh", 1)) {
					if (ui.button("Export")) {
						arm.App.showFiles = true;
						@:privateAccess zui.Ext.lastPath = ""; // Refresh
						arm.App.whandle.redraws = 2;
						arm.App.foldersOnly = true;
						arm.App.showFilename = true;
						arm.App.filesDone = function(path:String) {
							var f = arm.App.filenameHandle.text;
							if (f == "") f = "untitled";
							Exporter.exportMesh(path + "/" + f);
						};
					}
					ui.combo(Id.handle(), ["obj"], "Format", true);
					var mesh = paintObject.data.raw;
					var inda = mesh.index_arrays[0].values;
					var tris = Std.int(inda.length / 3);
					ui.text(tris + " triangles");
				}

				ui.separator();
				if (ui.panel(Id.handle({selected: true}), "Export Textures", 1)) {

					if (ui.button("Export")) {
						arm.App.showFiles = true;
						@:privateAccess zui.Ext.lastPath = ""; // Refresh
						arm.App.whandle.redraws = 2;
						arm.App.foldersOnly = true;
						arm.App.showFilename = true;
						// var path = 'C:\\Users\\lubos\\Documents\\';
						arm.App.filesDone = function(path:String) {
							textureExport = true;
							textureExportPath = path;
						}
					}
					if (ui.isHovered) ui.tooltip("Export texture files (Ctrl + Shift + E)");

					formatType = ui.combo(Id.handle({position: formatType}), ["jpg", "png"], "Format", true);
					if (formatType == 0) {
						formatQuality = ui.slider(Id.handle({value: formatQuality}), "Quality", 0.0, 100.0, true, 1);
					}
					outputType = ui.combo(Id.handle(), ["Generic", "UE4 (ORM)"], "Output", true);
					ui.text("Export Maps");
					ui.row([1/2, 1/2]);
					isBase = ui.check(Id.handle({selected: isBase}), "Base Color");
					isBaseSpace = ui.combo(Id.handle({position: isBaseSpace}), ["linear", "srgb"], "Space");
					ui.row([1/2, 1/2]);
					isOpac = ui.check(Id.handle({selected: isOpac}), "Opacity");
					isOpacSpace = ui.combo(Id.handle({position: isOpacSpace}), ["linear", "srgb"], "Space");
					ui.row([1/2, 1/2]);
					isOcc = ui.check(Id.handle({selected: isOcc}), "Occlusion");
					isOccSpace = ui.combo(Id.handle({position: isOccSpace}), ["linear", "srgb"], "Space");
					ui.row([1/2, 1/2]);
					isRough = ui.check(Id.handle({selected: isRough}), "Roughness");
					isRoughSpace = ui.combo(Id.handle({position: isRoughSpace}), ["linear", "srgb"], "Space");
					ui.row([1/2, 1/2]);
					isMet = ui.check(Id.handle({selected: isMet}), "Metallic");
					isMetSpace = ui.combo(Id.handle({position: isMetSpace}), ["linear", "srgb"], "Space");
					ui.row([1/2, 1/2]);
					isNor = ui.check(Id.handle({selected: isNor}), "Normal");
					isNorSpace = ui.combo(Id.handle({position: isNorSpace}), ["linear", "srgb"], "Space");
					ui.row([1/2, 1/2]);
					isEmis = ui.check(Id.handle({selected: isEmis}), "Emission");
					isEmisSpace = ui.combo(Id.handle({position: isEmisSpace}), ["linear", "srgb"], "Space");
					ui.row([1/2, 1/2]);
					isHeight = ui.check(Id.handle({selected: isHeight}), "Height");
					isHeightSpace = ui.combo(Id.handle({position: isHeightSpace}), ["linear", "srgb"], "Space");
					ui.row([1/2, 1/2]);
					isSubs = ui.check(Id.handle({selected: isSubs}), "Subsurface");
					isSubsSpace = ui.combo(Id.handle({position: isSubsSpace}), ["linear", "srgb"], "Space");
				}
			}

			if (ui.tab(htab2, "Viewport")) {
				if (ui.button("Import Envmap")) {
					arm.App.showFiles = true;
					@:privateAccess zui.Ext.lastPath = ""; // Refresh
					arm.App.whandle.redraws = 2;
					arm.App.foldersOnly = false;
					arm.App.showFilename = false;
					arm.App.filesDone = function(path:String) {
						if (!StringTools.endsWith(path, ".hdr")) {
							UITrait.inst.showError("Error: .hdr file expected");
							return;
						}
						Importer.importFile(path);
					}
				}

				if (iron.Scene.active.world.probe.radianceMipmaps.length > 0) {
					ui.image(iron.Scene.active.world.probe.radianceMipmaps[0]);
				}

				ui.row([1/2, 1/2]);
				var modeHandle = Id.handle({position: 0});
				viewportMode = ui.combo(modeHandle, ["Render", "Base Color", "Normal Map", "Occlusion", "Roughness", "Metallic", "TexCoord", "Normal", "MaterialID", "Mask"], "Mode");
				if (modeHandle.changed) {
					UINodes.inst.parseMeshMaterial();
				}
				var p = iron.Scene.active.world.probe;
				// var envType = ui.combo(Id.handle({position: 0}), ["Indoor"], "Envmap");
				var envHandle = Id.handle({value: p.raw.strength});
				p.raw.strength = ui.slider(envHandle, "Environment", 0.0, 8.0, true);
				if (envHandle.changed) ddirty = 2;
				
				ui.row([1/2, 1/2]);
				if (iron.Scene.active.lights.length > 0) {
					var light = iron.Scene.active.lights[0];

					var sxhandle = Id.handle();
					sxhandle.value = light.data.raw.size;
					light.data.raw.size = ui.slider(sxhandle, "Light Size", 0.0, 4.0, true);
					if (sxhandle.changed) ddirty = 2;
					// var syhandle = Id.handle();
					// syhandle.value = light.data.raw.size_y;
					// light.data.raw.size_y = ui.slider(syhandle, "Size Y", 0.0, 4.0, true);
					// if (syhandle.changed) ddirty = 2;
					
					var lhandle = Id.handle();
					lhandle.value = light.data.raw.strength / 1333;
					lhandle.value = Std.int(lhandle.value * 100) / 100;
					light.data.raw.strength = ui.slider(lhandle, "Light", 0.0, 4.0, true) * 1333;
					if (lhandle.changed) ddirty = 2;
				}

				ui.row([1/2, 1/2]);
				drawWireframe = ui.check(wireframeHandle, "Wireframe");
				if (wireframeHandle.changed) {
					ui.g.end();
					UIView2D.inst.cacheUVMap();
					ui.g.begin(false);
					UINodes.inst.parseMeshMaterial();
				}
				showGrid = ui.check(Id.handle({selected: showGrid}), "Grid");

				ui.row([1/2, 1/2]);
				showEnvmap = ui.check(showEnvmapHandle, "Envmap");
				if (showEnvmapHandle.changed) {
					ddirty = 2;
				}
				var compassHandle = Id.handle({selected: showCompass});
				showCompass = ui.check(compassHandle, "Compass");
				if (compassHandle.changed) ddirty = 2;

				if (showEnvmap) {
					showEnvmapBlur = ui.check(showEnvmapBlurHandle, "Blurred");
					if (showEnvmapBlurHandle.changed) {
						var probe = iron.Scene.active.world.probe;
						savedEnvmap = showEnvmapBlur ? probe.radianceMipmaps[0] : probe.radiance;
						ddirty = 2;
					}
				}
				else {
					if (ui.panel(Id.handle({selected: false}), "Viewport Color")) {
						var hwheel = Id.handle({color: 0xff030303});
						var worldColor:kha.Color = Ext.colorWheel(ui, hwheel);
						if (hwheel.changed) {
							var b = emptyEnvmap.lock();
							b.set(0, worldColor.Rb);
							b.set(1, worldColor.Gb);
							b.set(2, worldColor.Bb);
							emptyEnvmap.unlock();
							ddirty = 2;
						}
					}
				}
				iron.Scene.active.world.envmap = showEnvmap ? savedEnvmap : emptyEnvmap;
			}
		}

		ui.end();
		g.begin(false);
	}

	function setObjectMask() {
		var ar = ["None"];
		for (p in paintObjects) ar.push(p.name);

		var mask = selectedLayer.objectMask;
		if (layerFilter > 0) mask = layerFilter;
		if (mask > 0) {
			if (mergedObject != null) mergedObject.visible = false;
			var o = paintObjects[0];
			for (p in paintObjects) if (p.name == ar[mask]) { o = p; break; }
			selectPaintObject(o);
		}
		else {
			if (mergedObject == null) {
				MeshUtil.mergeMesh();
			}
			selectPaintObject(mainObject());
			paintObject.skip_context = "paint";
			mergedObject.visible = true;
		}
	}

	public function updateCameraType(cameraType:Int) {
		var cam = iron.Scene.active.cameras[0];
		if (cameraType == 0) {
			cam.data.raw.ortho = null;
			cam.buildProjection();
		}
		else {
			var f32 = new kha.arrays.Float32Array(4);
			f32[0] = -2;
			f32[1] =  2;
			f32[2] = -2 * (iron.App.h() / iron.App.w());
			f32[3] =  2 * (iron.App.h() / iron.App.w());
			cam.data.raw.ortho = f32;
			cam.buildProjection();
		}
		ddirty = 2;
	}

	public function getTextToolFont():kha.Font {
		var fontName = Importer.fontList[textToolHandle.position];
		if (fontName == 'default.ttf') return UITrait.inst.ui.ops.font;
		return Importer.fontMap.get(fontName);
	}

	function f32(ar:Array<kha.FastFloat>):kha.arrays.Float32Array {
		var res = new kha.arrays.Float32Array(ar.length);
		for (i in 0...ar.length) res[i] = ar[i];
		return res;
	}

	function initParticle() {
		if (particleMaterial != null) return;

		var raw:TParticleData = {
			name: "Particles",
			type: 0,
			loop: false,
			render_emitter: false,
			count: 1000,
			frame_start: 0,
			frame_end: 1000,
			lifetime: 400,
			lifetime_random: 0.5,
			emit_from: 1,
			object_align_factor: f32([0, 0, -40]),
			factor_random: 2.0,
			physics_type: 0,
			particle_size: 1.0,
			size_random: 0,
			mass: 1,
			instance_object: ".Particle",
			weight_gravity: 1
		};
		// iron.Scene.active.raw.gravity = f32([0, 0, -9.8]);
		iron.Scene.active.raw.particle_datas = [raw];
		var particle_refs:Array<TParticleReference> = [
			{
				name: "Particles",
				particle: "Particles",
				seed: 0
			}
		];

		{
			var t = new iron.RenderPath.RenderTargetRaw();
			t.name = "texparticle";
			t.width = 0;
			t.height = 0;
			t.format = 'R8';
			t.scale = armory.renderpath.Inc.getSuperSampling();
			iron.RenderPath.active.createRenderTarget(t);
		}

		for (mat in iron.Scene.active.raw.material_datas) {
			if (mat.name == 'Material2') {
				var m = Reflect.copy(mat);
				m.name = 'MaterialParticle';
				iron.Scene.active.raw.material_datas.push(m);
				break;
			}
		}

		iron.data.Data.getMaterial("Scene", "MaterialParticle", function(md:iron.data.MaterialData) {
			particleMaterial = md;

			for (obj in iron.Scene.active.raw.objects) {
				if (obj.name == '.Sphere') {
					var particle = Reflect.copy(obj);
					particle.name = '.Particle';
					particle.is_particle = true;
					particle.material_refs = ['MaterialParticle'];
					iron.Scene.active.raw.objects.push(particle);
					for (i in 0...16) particle.transform.values[i] *= 0.01;
					break;
				}
			}

			iron.Scene.active.spawnObject(".Sphere", null, function(o:Object) {
				var mo:MeshObject = cast o;
				mo.name = ".ParticleEmitter";
				mo.raw.particle_refs = particle_refs;
				mo.setupParticleSystem("Scene", particle_refs[0]);
			});
		});
	}
}

@:enum abstract PaintTool(Int) from Int to Int {
	var ToolBrush = 0;
	var ToolEraser = 1;
	var ToolFill = 2;
	var ToolBake = 3;
	var ToolColorId = 4;
	var ToolDecal = 5;
	var ToolText = 6;
	var ToolClone = 7;
	var ToolBlur = 8;
	var ToolParticle = 9;
	var ToolPicker = 10;
}

@:enum abstract SceneTool(Int) from Int to Int {
	var ToolGizmo = 0;
}

@:enum abstract WorkMode(Int) from Int to Int {
	var ModePaint = 0;
	var ModeScene = 1;
	var ModeMaterial = 2;
}
