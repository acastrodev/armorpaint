package arm;

import iron.data.SceneFormat;
import iron.data.MeshData;
import arm.ProjectFormat;
import arm.util.*;
import arm.ui.*;

class Project {
	public static function projectOpen() {
		arm.App.showFiles = true;
		@:privateAccess zui.Ext.lastPath = ""; // Refresh
		arm.App.whandle.redraws = 2;
		arm.App.foldersOnly = false;
		arm.App.showFilename = false;
		arm.App.filesDone = function(path:String) {
			if (!StringTools.endsWith(path, ".arm")) {
				UITrait.inst.showError("Error: .arm file expected");
				return;
			}

			var current = @:privateAccess kha.graphics4.Graphics2.current;
			if (current != null) current.end();

			importProject(path);

			if (current != null) current.begin(false);
		};
	}

	static function toRelative(from:String, to:String) {
		from = haxe.io.Path.normalize(from);
		to = haxe.io.Path.normalize(to);
		var a = from.split("/");
		var b = to.split("/");
		while (a[0] == b[0]) {
			a.shift();
			b.shift();
			if (a.length == 0 || b.length == 0) break;
		}
		var base = "";
		for (i in 0...a.length - 1) base += "../";
		base += b.join("/");
		return haxe.io.Path.normalize(base);
	}

	static function baseDir(path:String) {
		path = haxe.io.Path.normalize(path);
		var base = path.substr(0, path.lastIndexOf("/") + 1);
		if (kha.System.systemId == "Windows") {
			// base = StringTools.replace(base, "/", "\\");
			base = base.substr(0, 2) + "\\" + base.substr(3);
		}
		return base;
	}

	public static function exportProject() {
		var mnodes:Array<zui.Nodes.TNodeCanvas> = [];
		var bnodes:Array<zui.Nodes.TNodeCanvas> = [];

		for (m in UITrait.inst.materials) {
			var c = Reflect.copy(UINodes.inst.canvasMap.get(m));
			for (n in c.nodes) {
				if (n.type == "TEX_IMAGE") {  // Convert image path from absolute to relative
					n.buttons[0].data = toRelative(UITrait.inst.projectPath, n.buttons[0].data);
				}
			}
			mnodes.push(c);
		}
		for (b in UITrait.inst.brushes) bnodes.push(UINodes.inst.canvasBrushMap.get(b));

		var md:Array<TMeshData> = [];
		for (p in UITrait.inst.paintObjects) md.push(p.data.raw);

		var asset_files:Array<String> = [];
		for (a in UITrait.inst.assets) {
			var rel = toRelative(UITrait.inst.projectPath, a.file);
			asset_files.push(rel);
		}

		var ld:Array<TLayerData> = [];
		for (l in UITrait.inst.layers) {
			ld.push({
				res: l.texpaint.width,
				texpaint: l.texpaint.getPixels(),
				texpaint_nor: l.texpaint_nor.getPixels(),
				texpaint_pack: l.texpaint_pack.getPixels()
			});
		}

		UITrait.inst.project = {
			version: arm.App.version,
			material_nodes: mnodes,
			brush_nodes: bnodes,
			mesh_datas: md,
			layer_datas: ld,
			assets: asset_files
		};
		
		var bytes = iron.system.ArmPack.encode(UITrait.inst.project);

		#if kha_krom
		Krom.fileSaveBytes(UITrait.inst.projectPath, bytes.getData());
		#elseif kha_kore
		sys.io.File.saveBytes(UITrait.inst.projectPath, bytes);
		#end
	}

	public static function projectSave() {
		if (UITrait.inst.projectPath == "") {
			projectSaveAs();
			return;
		}
		kha.Window.get(0).title = arm.App.filenameHandle.text + " - ArmorPaint";
		UITrait.inst.projectExport = true;
	}

	public static function projectSaveAs() {
		arm.App.showFiles = true;
		@:privateAccess zui.Ext.lastPath = ""; // Refresh
		arm.App.whandle.redraws = 2;
		arm.App.foldersOnly = true;
		arm.App.showFilename = true;
		arm.App.filesDone = function(path:String) {
			var f = arm.App.filenameHandle.text;
			if (f == "") f = "untitled";
			UITrait.inst.projectPath = path + "/" + f;
			if (!StringTools.endsWith(UITrait.inst.projectPath, ".arm")) UITrait.inst.projectPath += ".arm";
			projectSave();
		};
	}

	public static function projectNew(resetLayers = true) {
		kha.Window.get(0).title = "ArmorPaint";
		UITrait.inst.projectPath = "";
		if (UITrait.inst.mergedObject != null) {
			UITrait.inst.mergedObject.remove();
			iron.data.Data.deleteMesh(UITrait.inst.mergedObject.data.handle);
			UITrait.inst.mergedObject = null;
		}

		UITrait.inst.layerPreviewDirty = true;
		LayerSlot.counter = 0;

		UITrait.inst.paintObject = UITrait.inst.mainObject();

		UITrait.inst.selectPaintObject(UITrait.inst.mainObject());
		for (i in 1...UITrait.inst.paintObjects.length) {
			var p = UITrait.inst.paintObjects[i];
			if (p == UITrait.inst.paintObject) continue;
			iron.data.Data.deleteMesh(p.data.handle);
			p.remove();
		}
		var n = UITrait.inst.newObjectNames[UITrait.inst.newObject];
		var handle = UITrait.inst.paintObject.data.handle;
		if (handle != "mesh_SphereSphere" && handle != "mesh_PlanePlane") {
			iron.data.Data.deleteMesh(handle);
		}
		iron.data.Data.getMesh("mesh_" + n, n, function(md:MeshData) {
			
			var current = @:privateAccess kha.graphics4.Graphics2.current;
			if (current != null) current.end();

			UITrait.inst.autoFillHandle.selected = false;
			UITrait.inst.pickerMaskHandle.position = 0;
			UITrait.inst.paintObject.setData(md);
			UITrait.inst.paintObject.transform.scale.set(1, 1, 1);
			UITrait.inst.paintObject.transform.buildMatrix();
			UITrait.inst.paintObject.name = n;
			UITrait.inst.paintObjects = [UITrait.inst.paintObject];
			// UITrait.inst.maskHandle.position = 0;
			// UITrait.inst.materials = [new MaterialSlot()];
			iron.data.Data.getMaterial("Scene", "Material", function(m:iron.data.MaterialData) {
				UITrait.inst.materials = [new MaterialSlot(m)];
			});
			UITrait.inst.selectedMaterial = UITrait.inst.materials[0];
			UINodes.inst.canvasMap = new Map();
			UINodes.inst.canvasBrushMap = new Map();
			UITrait.inst.brushes = [new BrushSlot()];
			UITrait.inst.selectedBrush = UITrait.inst.brushes[0];
			
			if (resetLayers) {
				// for (l in layers) l.unload();
				UITrait.inst.layers = [new LayerSlot()];
				UITrait.inst.setLayer(UITrait.inst.layers[0]);
				iron.App.notifyOnRender(Layers.initLayers);
			}
			
			UINodes.inst.updateCanvasMap();
			UINodes.inst.parsePaintMaterial();
			RenderUtil.makeMaterialPreview();
			UITrait.inst.assets = [];
			UITrait.inst.assetNames = [];
			UITrait.inst.assetId = 0;
			ViewportUtil.resetViewport();
			UITrait.inst.ddirty = 4;
			UITrait.inst.hwnd.redraws = 2;
			UITrait.inst.hwnd1.redraws = 2;
			UITrait.inst.hwnd2.redraws = 2;

			if (current != null) current.begin(false);
		});
	}

	public static function importProject(path:String) {
		iron.data.Data.getBlob(path, function(b:kha.Blob) {

			UITrait.inst.layerPreviewDirty = true;
			LayerSlot.counter = 0;

			var resetLayers = false;
			projectNew(resetLayers);
			UITrait.inst.projectPath = path;
			arm.App.filenameHandle.text = new haxe.io.Path(UITrait.inst.projectPath).file;

			kha.Window.get(0).title = arm.App.filenameHandle.text + " - ArmorPaint";

			UITrait.inst.project = iron.system.ArmPack.decode(b.toBytes());
			var project = UITrait.inst.project;

			var base = baseDir(path);

			for (file in project.assets) {
				var abs = base + file;
				var exists = 1;
				if (kha.System.systemId == "Windows") {
					exists = Krom.sysCommand('IF EXIST "' + abs + '" EXIT /b 1');
				}
				//else { test -e file && echo 1 || echo 0 }
				if (exists == 0) {
					trace("Could not locate texture " + abs);
					var b = haxe.io.Bytes.alloc(4);
					b.set(0, 255);
					b.set(1, 0);
					b.set(2, 255);
					b.set(3, 255);
					var pink = kha.Image.fromBytes(b, 1, 1);
					iron.data.Data.cachedImages.set(abs, pink);
				}
				Importer.importTexture(abs);
			}

			var m0:iron.data.MaterialData = null;
			iron.data.Data.getMaterial("Scene", "Material", function(m:iron.data.MaterialData) {
				m0 = m;
			});

			UITrait.inst.materials = [];
			for (n in project.material_nodes) {
				for (node in n.nodes) {
					if (node.type == "TEX_IMAGE") { // Convert image path from relative to absolute
						var abs = base + node.buttons[0].data;
						node.buttons[0].data = abs;
					}
					for (inp in node.inputs) { // Round input socket values
						if (inp.type == "VALUE") inp.default_value = Math.round(inp.default_value * 100) / 100;
					}
				}
				var mat = new MaterialSlot(m0);
				UINodes.inst.canvasMap.set(mat, n);
				UITrait.inst.materials.push(mat);

				UITrait.inst.selectedMaterial = mat;
				UINodes.inst.updateCanvasMap();
				UINodes.inst.parsePaintMaterial();
				RenderUtil.makeMaterialPreview();
			}

			UITrait.inst.brushes = [];
			for (n in project.brush_nodes) {
				var brush = new BrushSlot();
				UINodes.inst.canvasBrushMap.set(brush, n);
				UITrait.inst.brushes.push(brush);
			}

			// Synchronous for now
			new MeshData(project.mesh_datas[0], function(md:MeshData) {
				UITrait.inst.paintObject.setData(md);
				UITrait.inst.paintObject.transform.scale.set(1, 1, 1);
				UITrait.inst.paintObject.transform.buildMatrix();
				UITrait.inst.paintObject.name = md.name;
				UITrait.inst.paintObjects = [UITrait.inst.paintObject];
			});

			for (i in 1...project.mesh_datas.length) {
				var raw = project.mesh_datas[i];  
				new MeshData(raw, function(md:MeshData) {
					var object = iron.Scene.active.addMeshObject(md, UITrait.inst.paintObject.materials, UITrait.inst.paintObject);
					object.name = md.name;
					object.skip_context = "paint";
					UITrait.inst.paintObjects.push(object);					
				});
			}

			// No mask by default
			if (UITrait.inst.mergedObject == null) MeshUtil.mergeMesh();
			UITrait.inst.selectPaintObject(UITrait.inst.mainObject());
			ViewportUtil.scaleToBounds();
			UITrait.inst.paintObject.skip_context = "paint";
			UITrait.inst.mergedObject.visible = true;

			UITrait.inst.resHandle.position = Config.getTextureResPos(project.layer_datas[0].res);

			if (UITrait.inst.layers[0].texpaint.width != Config.getTextureRes()) {
				var i = 0;
				for (l in UITrait.inst.layers) {
					Layers.resizeLayer(l, i == 0);
					if (i > 0) l.texpaint.setDepthStencilFrom(UITrait.inst.layers[0].texpaint);
					i++;
				}
				for (l in UITrait.inst.undoLayers) {
					Layers.resizeLayer(l, false);
					l.texpaint.setDepthStencilFrom(UITrait.inst.layers[0].texpaint);
				}
				var rts = iron.RenderPath.active.renderTargets;
				rts.get("texpaint_blend0").image.unload();
				rts.get("texpaint_blend0").raw.width = Config.getTextureRes();
				rts.get("texpaint_blend0").raw.height = Config.getTextureRes();
				rts.get("texpaint_blend0").image = kha.Image.createRenderTarget(Config.getTextureRes(), Config.getTextureRes(), kha.graphics4.TextureFormat.L8, kha.graphics4.DepthStencilFormat.NoDepthAndStencil);
				rts.get("texpaint_blend1").image.unload();
				rts.get("texpaint_blend1").raw.width = Config.getTextureRes();
				rts.get("texpaint_blend1").raw.height = Config.getTextureRes();
				rts.get("texpaint_blend1").image = kha.Image.createRenderTarget(Config.getTextureRes(), Config.getTextureRes(), kha.graphics4.TextureFormat.L8, kha.graphics4.DepthStencilFormat.NoDepthAndStencil);
				UITrait.inst.brushBlendDirty = true;
			}

			// for (l in UITrait.inst.layers) l.unload();
			UITrait.inst.layers = [];
			for (i in 0...project.layer_datas.length) {
				var ld = project.layer_datas[i];
				var l = new LayerSlot();
				UITrait.inst.layers.push(l);

				// TODO: create render target from bytes
				var texpaint = kha.Image.fromBytes(ld.texpaint, ld.res, ld.res);
				l.texpaint.g2.begin(false);
				l.texpaint.g2.drawImage(texpaint, 0, 0);
				l.texpaint.g2.end();
				// texpaint.unload();

				var texpaint_nor = kha.Image.fromBytes(ld.texpaint_nor, ld.res, ld.res);
				l.texpaint_nor.g2.begin(false);
				l.texpaint_nor.g2.drawImage(texpaint_nor, 0, 0);
				l.texpaint_nor.g2.end();
				// texpaint_nor.unload();

				var texpaint_pack = kha.Image.fromBytes(ld.texpaint_pack, ld.res, ld.res);
				l.texpaint_pack.g2.begin(false);
				l.texpaint_pack.g2.drawImage(texpaint_pack, 0, 0);
				l.texpaint_pack.g2.end();
				// texpaint_pack.unload();
			}
			UITrait.inst.setLayer(UITrait.inst.layers[0]);

			UITrait.inst.ddirty = 4;
			UITrait.inst.hwnd.redraws = 2;
			UITrait.inst.hwnd1.redraws = 2;
			UITrait.inst.hwnd2.redraws = 2;

			iron.data.Data.deleteBlob(path);
		});
	}
}
