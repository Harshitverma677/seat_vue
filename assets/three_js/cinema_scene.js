/**
 * Seat View — Photorealistic Three.js 3D Cinema Auditorium
 * 
 * Features:
 * - 126 Photorealistic Volumetric 3D Cinema Seats (9 Rows A-I x 14 Columns)
 * - Sculpted cushions, ergonomic tilted backrests, headrests, armrests with cup holders, steel pedestals
 * - Rows A-H Standard Seats (Deep Crimson Velvet #9B111E, Matte Black Armrests)
 * - Row I Recliner Seats (Plush #221416 Upholstery, Extended Footrests, Dual Cup Holders)
 * - Selected Seat in Mint Green (#34D399) with subtle physical rim sheen (no neon glow)
 * - Complete Enclosed Architectural Auditorium:
 *     * Concave 2.40:1 Curved Cinema Screen with high-detail desert cinematic visual
 *     * Tiered Stepped Auditorium Floor with Speckled Cinema Carpet
 *     * Left and Right Acoustic Walls with 3D Fabric Panels, Reveals, and Warm LED Sconces
 *     * Coffered Acoustic Ceiling with Transverse Baffles and Screen Bounce Illumination
 *     * Rear Wall with Projection Booth Window, Faint Projection Beam, and Exit Signs
 * - Screen-Driven Global Illumination (GI) Setup:
 *     * Screen Key Light with PCF Soft Shadows
 *     * Left and Right Screen Bounce Lights washing acoustic walls
 *     * Ceiling Screen Wash Light & Stage Floor Spill
 *     * Subtle dynamic 24fps film projection breathing / flicker
 *     * Hemisphere ambient fill (dark cinema eye-adaptation)
 * - Seated First-Person Eye Level POV with Expanded Drag-to-Look (Walls, Ceiling, Foreground Seats)
 * - Fullscreen Landscape Camera Adaptation (FOV 42° widescreen Scope framing)
 */

(function () {
  'use strict';

  // --- Scene Handles ---
  let scene, camera, renderer, container;
  let screenMesh;
  const seatMeshes = {}; // Map of seatId -> { group, cushions: [], isRecliner }
  let activeSeatId = 'I12';

  // Screen-driven dynamic lighting handles
  let screenKeyLight, leftWallBounceLight, rightWallBounceLight, ceilingBounceLight;
  let projectionBeamMesh;

  // Camera State
  const cameraState = {
    currentPos: new THREE.Vector3(0, 8.8, 19.2),
    currentLook: new THREE.Vector3(0, 4.3, 4.0),
    overheadPos: new THREE.Vector3(0, 8.8, 19.2),
    overheadLook: new THREE.Vector3(0, 4.3, 4.0),
    startPos: new THREE.Vector3(0, 8.8, 19.2),
    startLook: new THREE.Vector3(0, 4.3, 4.0),
    targetEyePos: new THREE.Vector3(0, 1.60, 8.5),
    targetLook: new THREE.Vector3(0, 4.3, 0.5),
    yaw: 0.0,
    pitch: 0.0,
    targetYaw: 0.0,
    targetPitch: 0.0,
    hasEnteredOverview: false,
    isTransitioning: false,
    transitionType: 'forward', // 'forward' | 'reverse'
    transitionStartTime: 0,
    transitionDuration: 1200, // ms
  };

  // Expanded look-around bounds: allow viewing walls, ceiling, rear depth, and foreground seats
  const MAX_YAW = 1.15; // ~66 degrees left/right
  const MAX_PITCH = 0.65; // ~37 degrees up/down

  let isFullscreenLandscape = false;
  let isInitialized = false;

  // Materials Cache
  let velvetCrimsonMaterial, velvetMintMaterial, reclinerMaterial;
  let armrestMaterial, metalPedestalMaterial, cupHolderMaterial;
  let carpetMaterial, acousticPanelMaterial, wallTrimMaterial, ceilingBaffleMaterial;
  let redAisleLightMaterial, sconceLightMaterial, screenMaterial, projectionBeamMaterial;
  let exitSignMaterial;

  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    setTimeout(init, 10);
  } else {
    document.addEventListener('DOMContentLoaded', init);
  }

  function init() {
    if (isInitialized) return;
    try {
      if (typeof THREE === 'undefined') {
        const el = document.getElementById('loading-indicator');
        if (el) el.innerHTML = 'ERROR: THREE is undefined';
        return;
      }
      isInitialized = true;
      container = document.getElementById('canvas-container');

      // 0. Run automated physical auditorium dimension validation checks
      if (window.CinemaDimensions) {
        const validation = window.CinemaDimensions.validateAuditorium();
        console.log('[CinemaDimensions] Real-World Auditorium Validation Report:', validation);
        if (!validation.isValid) {
          console.warn('[CinemaDimensions] Some architectural checks failed:', validation.checks);
        }
      }

      // 1. Scene
      scene = new THREE.Scene();
      scene.background = new THREE.Color(0x060608);
      scene.fog = new THREE.FogExp2(0x060608, 0.018);

      // 2. Camera
      const aspect = window.innerWidth / window.innerHeight;
      camera = new THREE.PerspectiveCamera(aspect > 1.0 ? 42.0 : 58.0, aspect, 0.1, 120.0);
      camera.position.copy(cameraState.currentPos);
      camera.lookAt(cameraState.currentLook);

      // 3. WebGL Renderer with Physically Correct Lighting & Tone Mapping
      renderer = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'high-performance' });
      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2.0));
      renderer.setSize(window.innerWidth, window.innerHeight);
      renderer.shadowMap.enabled = true;
      renderer.shadowMap.type = THREE.PCFSoftShadowMap;
      renderer.toneMapping = THREE.ACESFilmicToneMapping;
      renderer.toneMappingExposure = 1.15;
      container.appendChild(renderer.domElement);

      // 4. Materials with Procedural PBR Textures
      initMaterials();

      // 5. Complete Architectural Auditorium (Walls, Ceiling, Floor, Rear Wall, Curved Screen)
      buildAuditoriumEnvironment();

      // 6. Detailed 3D Cinema Recliners & Standard Seats (126 Seats)
      buildAuditoriumSeats();

      // 7. Screen-Driven Global Illumination Setup
      setupCinematicLighting();

      // 8. Event Listeners & Touch Controls
      window.addEventListener('resize', onWindowResize);
      setupTouchControls();

      // 9. Hide Loading Indicator
      const loadingElem = document.getElementById('loading-indicator');
      if (loadingElem) {
        loadingElem.style.opacity = '0';
        setTimeout(() => loadingElem.remove(), 350);
      }

      // 10. Start Render Loop
      animate(0);

      sendToFlutter({ type: 'sceneReady' });
    } catch (e) {
      const el = document.getElementById('loading-indicator');
      if (el) el.innerHTML = 'INIT EXCEPTION: ' + e.message;
      console.error('Init error:', e);
    }
  }

  // --- Procedural Texture Generators ---
  function createVelvetBumpTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 128;
    canvas.height = 128;
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#808080';
    ctx.fillRect(0, 0, 128, 128);

    // Fine velvet weave noise
    const imgData = ctx.getImageData(0, 0, 128, 128);
    const data = imgData.data;
    for (let i = 0; i < data.length; i += 4) {
      const noise = (Math.random() - 0.5) * 32;
      const val = Math.min(255, Math.max(0, 128 + noise));
      data[i] = val;
      data[i + 1] = val;
      data[i + 2] = val;
    }
    ctx.putImageData(imgData, 0, 0);

    const texture = new THREE.CanvasTexture(canvas);
    texture.wrapS = THREE.RepeatWrapping;
    texture.wrapT = THREE.RepeatWrapping;
    texture.repeat.set(8, 8);
    return texture;
  }

  function createCarpetTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 256;
    canvas.height = 256;
    const ctx = canvas.getContext('2d');

    // Dark charcoal base
    ctx.fillStyle = '#121217';
    ctx.fillRect(0, 0, 256, 256);

    // Speckled cinema carpet flecks (subtle crimson and dark grey dots)
    for (let i = 0; i < 2800; i++) {
      const x = Math.random() * 256;
      const y = Math.random() * 256;
      const r = Math.random();
      if (r < 0.25) {
        ctx.fillStyle = '#261619'; // Subtle crimson fleck
      } else if (r < 0.65) {
        ctx.fillStyle = '#1b1b22'; // Slate grey fleck
      } else {
        ctx.fillStyle = '#0a0a0d'; // Deep charcoal fleck
      }
      ctx.fillRect(x, y, 1.8, 1.8);
    }

    const texture = new THREE.CanvasTexture(canvas);
    texture.wrapS = THREE.RepeatWrapping;
    texture.wrapT = THREE.RepeatWrapping;
    texture.repeat.set(12, 16);
    return texture;
  }

  function createAcousticPanelTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 256;
    canvas.height = 256;
    const ctx = canvas.getContext('2d');

    ctx.fillStyle = '#18181f';
    ctx.fillRect(0, 0, 256, 256);

    // Subtle vertical acoustic ribbing
    for (let x = 0; x < 256; x += 4) {
      ctx.fillStyle = x % 8 === 0 ? '#14141a' : '#1d1d25';
      ctx.fillRect(x, 0, 2, 256);
    }

    const texture = new THREE.CanvasTexture(canvas);
    texture.wrapS = THREE.RepeatWrapping;
    texture.wrapT = THREE.RepeatWrapping;
    texture.repeat.set(2, 6);
    return texture;
  }

  function createCinemaScreenTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 1024;
    canvas.height = 450;
    const ctx = canvas.getContext('2d');

    // Warm cinematic atmospheric sky gradient
    const skyGrad = ctx.createLinearGradient(0, 0, 0, 290);
    skyGrad.addColorStop(0, '#5e3e29');
    skyGrad.addColorStop(0.35, '#8c5d3a');
    skyGrad.addColorStop(0.7, '#c69567');
    skyGrad.addColorStop(1, '#e5be94');
    ctx.fillStyle = skyGrad;
    ctx.fillRect(0, 0, 1024, 290);

    // Sun haze atmosphere
    const sunGrad = ctx.createRadialGradient(512, 230, 20, 512, 230, 420);
    sunGrad.addColorStop(0, 'rgba(255, 248, 230, 0.75)');
    sunGrad.addColorStop(0.4, 'rgba(240, 195, 145, 0.35)');
    sunGrad.addColorStop(1, 'rgba(0, 0, 0, 0)');
    ctx.fillStyle = sunGrad;
    ctx.fillRect(0, 0, 1024, 290);

    // Far desert dune ridge
    ctx.fillStyle = '#b78c60';
    ctx.beginPath();
    ctx.moveTo(0, 280);
    ctx.quadraticCurveTo(280, 225, 550, 290);
    ctx.quadraticCurveTo(820, 350, 1024, 255);
    ctx.lineTo(1024, 450);
    ctx.lineTo(0, 450);
    ctx.closePath();
    ctx.fill();

    // Midground dune ridge with shadow slope
    ctx.fillStyle = '#8f5f36';
    ctx.beginPath();
    ctx.moveTo(0, 340);
    ctx.quadraticCurveTo(400, 285, 750, 385);
    ctx.lineTo(1024, 325);
    ctx.lineTo(1024, 450);
    ctx.lineTo(0, 450);
    ctx.closePath();
    ctx.fill();

    // Foreground sweeping main dune ridge (sharp crest)
    const duneGrad = ctx.createLinearGradient(0, 330, 1024, 450);
    duneGrad.addColorStop(0, '#be8f5d');
    duneGrad.addColorStop(0.55, '#a47141');
    duneGrad.addColorStop(1, '#6b4324');
    ctx.fillStyle = duneGrad;
    ctx.beginPath();
    ctx.moveTo(0, 380);
    ctx.quadraticCurveTo(340, 335, 680, 415);
    ctx.quadraticCurveTo(860, 450, 1024, 385);
    ctx.lineTo(1024, 450);
    ctx.lineTo(0, 450);
    ctx.closePath();
    ctx.fill();

    // Shadow flank of foreground dune
    const shadowFlank = ctx.createLinearGradient(510, 335, 1024, 450);
    shadowFlank.addColorStop(0, '#422716');
    shadowFlank.addColorStop(1, '#23140b');
    ctx.fillStyle = shadowFlank;
    ctx.beginPath();
    ctx.moveTo(512, 350);
    ctx.quadraticCurveTo(680, 385, 1024, 370);
    ctx.lineTo(1024, 450);
    ctx.lineTo(620, 450);
    ctx.closePath();
    ctx.fill();

    // Wanderer silhouette on dune crest
    ctx.fillStyle = '#140d09';
    ctx.beginPath();
    ctx.arc(512, 274, 3.5, 0, Math.PI * 2);
    ctx.rect(510, 278, 4, 11);
    ctx.fill();

    const texture = new THREE.CanvasTexture(canvas);
    texture.minFilter = THREE.LinearFilter;
    texture.magFilter = THREE.LinearFilter;
    return texture;
  }

  function initMaterials() {
    const velvetBump = createVelvetBumpTexture();
    const carpetTex = createCarpetTexture();
    const wallTex = createAcousticPanelTexture();
    const screenTex = createCinemaScreenTexture();

    // 1. Crimson Red Velvet Seats (#9B111E to #B91C1C)
    velvetCrimsonMaterial = new THREE.MeshStandardMaterial({
      color: 0x9b111e,
      roughness: 0.72,
      metalness: 0.04,
      bumpMap: velvetBump,
      bumpScale: 0.003,
    });

    // 2. Selected Seat Mint Green (#34D399) - Physical velvet with subtle rim sheen
    velvetMintMaterial = new THREE.MeshStandardMaterial({
      color: 0x34d399,
      roughness: 0.68,
      metalness: 0.05,
      emissive: 0x064e3b,
      emissiveIntensity: 0.16,
      bumpMap: velvetBump,
      bumpScale: 0.003,
    });

    // 3. Recliner Upholstery (#221416)
    reclinerMaterial = new THREE.MeshStandardMaterial({
      color: 0x221416,
      roughness: 0.74,
      metalness: 0.06,
      bumpMap: velvetBump,
      bumpScale: 0.003,
    });

    // 4. Matte Charcoal Armrest Body
    armrestMaterial = new THREE.MeshStandardMaterial({
      color: 0x161619,
      roughness: 0.58,
      metalness: 0.12,
    });

    // 5. Metal Pedestal Posts & Flanges
    metalPedestalMaterial = new THREE.MeshStandardMaterial({
      color: 0x1e1e22,
      roughness: 0.32,
      metalness: 0.85,
    });

    // 6. Integrated Cup Holders
    cupHolderMaterial = new THREE.MeshStandardMaterial({
      color: 0x09090b,
      roughness: 0.40,
      metalness: 0.70,
    });

    // 7. Cinema Carpet Floor
    carpetMaterial = new THREE.MeshStandardMaterial({
      map: carpetTex,
      roughness: 0.94,
      metalness: 0.02,
    });

    // 8. Acoustic Fabric Wall Panels
    acousticPanelMaterial = new THREE.MeshStandardMaterial({
      color: 0x1a1a20,
      roughness: 0.88,
      metalness: 0.04,
      map: wallTex,
    });

    // 9. Wall Trim & Reveal Channels
    wallTrimMaterial = new THREE.MeshStandardMaterial({
      color: 0x09090c,
      roughness: 0.50,
      metalness: 0.35,
    });

    // 10. Acoustic Ceiling Baffles
    ceilingBaffleMaterial = new THREE.MeshStandardMaterial({
      color: 0x0d0d10,
      roughness: 0.92,
      metalness: 0.02,
    });

    // 11. Red Aisle Step Illumination Strips
    redAisleLightMaterial = new THREE.MeshBasicMaterial({
      color: 0xd92626,
    });

    // 12. Sconce Fixture Emitters
    sconceLightMaterial = new THREE.MeshBasicMaterial({
      color: 0xffd7b5,
    });

    // 13. Cinema Screen Emissive Material
    screenMaterial = new THREE.MeshStandardMaterial({
      map: screenTex,
      emissive: 0xffedd5,
      emissiveMap: screenTex,
      emissiveIntensity: 0.96,
      roughness: 0.88,
      metalness: 0.0,
      side: THREE.DoubleSide,
    });

    // 14. Emergency Exit Sign
    exitSignMaterial = new THREE.MeshBasicMaterial({
      color: 0x10b981,
    });

    // 15. Atmospheric Projection Beam Material
    projectionBeamMaterial = new THREE.MeshBasicMaterial({
      color: 0xbdd7ff,
      transparent: true,
      opacity: 0.032,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
    });
  }

  // --- Complete Architectural Auditorium ---
  function buildAuditoriumEnvironment() {
    const D = window.CinemaDimensions;
    const derived = D.computeDerivedDimensions();

    // 1. Concave Curved Cinema Screen (2.40:1 Scope Widescreen)
    const screenWidth = D.screen.width;
    const screenHeight = D.screen.height;
    const curveRadius = D.screen.curvatureRadius;
    const segments = 32;

    const screenGeometry = new THREE.PlaneGeometry(screenWidth, screenHeight, segments, 1);
    const pos = screenGeometry.attributes.position;
    for (let i = 0; i < pos.count; i++) {
      const x = pos.getX(i);
      const zOffset = curveRadius - Math.sqrt(Math.max(0, curveRadius * curveRadius - x * x));
      pos.setZ(i, zOffset);
    }
    screenGeometry.computeVertexNormals();

    screenMesh = new THREE.Mesh(screenGeometry, screenMaterial);
    screenMesh.position.set(0, D.screen.centerElevation, D.screen.zPlane);
    scene.add(screenMesh);

    // Beveled Outer Cinema Screen Frame
    const frameGeometry = new THREE.PlaneGeometry(screenWidth + 0.32, screenHeight + 0.32, segments, 1);
    const fPos = frameGeometry.attributes.position;
    for (let i = 0; i < fPos.count; i++) {
      const x = fPos.getX(i);
      const zOffset = curveRadius - Math.sqrt(Math.max(0, curveRadius * curveRadius - x * x));
      fPos.setZ(i, zOffset - 0.04);
    }
    frameGeometry.computeVertexNormals();

    const frameMesh = new THREE.Mesh(frameGeometry, wallTrimMaterial);
    frameMesh.position.copy(screenMesh.position);
    scene.add(frameMesh);

    // Stage Apron / Speaker Skirt below screen (1.90m height up to screen bottom)
    const skirtHeight = D.screen.bottomElevation;
    const skirtGeo = new THREE.BoxGeometry(derived.auditoriumWidth - 0.4, skirtHeight, 1.2);
    const skirtMesh = new THREE.Mesh(skirtGeo, ceilingBaffleMaterial);
    skirtMesh.position.set(0, skirtHeight / 2.0, 0.4);
    scene.add(skirtMesh);

    // 2. Tiered Auditorium Floor with Carpet
    const rowZs = D.computeRowZDistances();
    for (let r = 0; r < D.layout.totalRows; r++) {
      const rowZ = rowZs[r];
      const rowY = D.riser.rowAFloorElevation + r * D.riser.rowRise;

      const stepGeo = new THREE.BoxGeometry(derived.auditoriumWidth, D.riser.rowRise, 1.4);
      const stepMesh = new THREE.Mesh(stepGeo, carpetMaterial);
      stepMesh.position.set(0, rowY - D.riser.rowRise / 2.0, rowZ);
      stepMesh.receiveShadow = true;
      scene.add(stepMesh);

      // Red Aisle Step LED Guide Strips under riser nosing
      const redLightGeo = new THREE.BoxGeometry(derived.auditoriumWidth - 0.2, 0.025, 0.03);
      const redLightMesh = new THREE.Mesh(redLightGeo, redAisleLightMaterial);
      redLightMesh.position.set(0, rowY - 0.015, rowZ - 0.70);
      scene.add(redLightMesh);
    }

    // Rear Walkway behind last row connecting to emergency exit doors and rear wall
    const lastRowZ = rowZs[D.layout.totalRows - 1];
    const rearWalkwayZStart = lastRowZ + 0.70;
    const rearWalkwayDepth = Math.max(0.5, derived.auditoriumLength - rearWalkwayZStart);
    const rearWalkwayCenterZ = rearWalkwayZStart + rearWalkwayDepth / 2.0;
    const rearWalkwayY = D.riser.rowAFloorElevation + (D.layout.totalRows - 1) * D.riser.rowRise;

    const walkwayGeo = new THREE.BoxGeometry(derived.auditoriumWidth, D.riser.rowRise, rearWalkwayDepth);
    const walkwayMesh = new THREE.Mesh(walkwayGeo, carpetMaterial);
    walkwayMesh.position.set(0, rearWalkwayY - D.riser.rowRise / 2.0, rearWalkwayCenterZ);
    walkwayMesh.receiveShadow = true;
    scene.add(walkwayMesh);

    // Front Stage Floor
    const frontFloorGeo = new THREE.BoxGeometry(derived.auditoriumWidth, 0.40, 4.5);
    const frontFloor = new THREE.Mesh(frontFloorGeo, carpetMaterial);
    frontFloor.position.set(0, 0.20, 2.0);
    frontFloor.receiveShadow = true;
    scene.add(frontFloor);

    // 3. Acoustic Side Walls with 3D Beveled Panels & LED Wall Sconces
    const halfWidth = derived.auditoriumWidth / 2.0;
    buildAcousticWall(-halfWidth, true, derived);  // Left Wall
    buildAcousticWall(halfWidth, false, derived);  // Right Wall

    // 4. Coffered Acoustic Ceiling with Transverse Baffles
    buildAcousticCeiling(derived);

    // 5. Rear Auditorium Wall with Projection Booth Window & Emergency Exits
    buildRearWall(derived);
  }

  function buildAcousticWall(xPos, isLeft, derived) {
    const wallGroup = new THREE.Group();
    const wallLength = derived.auditoriumLength;

    // Base structural backing wall
    const backWallGeo = new THREE.BoxGeometry(0.2, derived.ceilingHeight, wallLength);
    const backWall = new THREE.Mesh(backWallGeo, wallTrimMaterial);
    backWall.position.set(xPos, derived.ceilingHeight / 2.0, wallLength / 2.0);
    backWall.receiveShadow = true;
    wallGroup.add(backWall);

    // 10 Large Acoustic Fabric Panels with Reveal Grooves
    const panelCount = 10;
    const panelWidth = (wallLength - 2.0) / panelCount - 0.15;
    const panelHeight = derived.ceilingHeight - 2.5;
    const panelDepth = 0.08;
    const panelGeo = new THREE.BoxGeometry(panelDepth, panelHeight, panelWidth);

    for (let i = 0; i < panelCount; i++) {
      const zPos = 1.5 + i * (panelWidth + 0.15) + panelWidth / 2.0;
      const panel = new THREE.Mesh(panelGeo, acousticPanelMaterial);
      panel.position.set(isLeft ? xPos + 0.10 : xPos - 0.10, derived.ceilingHeight / 2.0 - 0.4, zPos);
      panel.receiveShadow = true;
      wallGroup.add(panel);

      // Warm Architectural LED Wall Sconces positioned in reveals between panels
      if (i > 0 && i < panelCount) {
        const sconceZ = zPos - panelWidth / 2.0 - 0.075;

        // Dark sconce fixture
        const fixtureGeo = new THREE.BoxGeometry(0.06, 0.40, 0.12);
        const fixture = new THREE.Mesh(fixtureGeo, metalPedestalMaterial);
        fixture.position.set(isLeft ? xPos + 0.12 : xPos - 0.12, 5.2, sconceZ);
        wallGroup.add(fixture);

        // Subtle glowing LED emitter core
        const emitterGeo = new THREE.BoxGeometry(0.04, 0.08, 0.08);
        const emitter = new THREE.Mesh(emitterGeo, sconceLightMaterial);
        emitter.position.set(isLeft ? xPos + 0.14 : xPos - 0.14, 5.2, sconceZ);
        wallGroup.add(emitter);

        // Warm accent point light on wall panel
        const wallLight = new THREE.PointLight(0xffdfba, 0.28, 4.5);
        wallLight.position.set(isLeft ? xPos + 0.45 : xPos - 0.45, 5.2, sconceZ);
        scene.add(wallLight);
      }
    }

    scene.add(wallGroup);
  }

  function buildAcousticCeiling(derived) {
    const ceilingGroup = new THREE.Group();
    const ceilHeight = derived.ceilingHeight;
    const ceilLength = derived.auditoriumLength;

    // Dark structural ceiling slab
    const slabGeo = new THREE.BoxGeometry(derived.auditoriumWidth, 0.2, ceilLength);
    const slab = new THREE.Mesh(slabGeo, ceilingBaffleMaterial);
    slab.position.set(0, ceilHeight, ceilLength / 2.0);
    slab.receiveShadow = true;
    ceilingGroup.add(slab);

    // Transverse Acoustic Ceiling Baffles spaced every 2.0m
    const baffleGeo = new THREE.BoxGeometry(derived.auditoriumWidth - 0.4, 0.45, 0.15);
    for (let z = 1.5; z <= ceilLength - 1.0; z += 2.0) {
      const baffle = new THREE.Mesh(baffleGeo, ceilingBaffleMaterial);
      baffle.position.set(0, ceilHeight - 0.25, z);
      baffle.receiveShadow = true;
      ceilingGroup.add(baffle);

      // Recessed cinema downlight trim rings
      [-3.5, 0.0, 3.5].forEach((x) => {
        const ringGeo = new THREE.CylinderGeometry(0.12, 0.12, 0.04, 16);
        const ring = new THREE.Mesh(ringGeo, wallTrimMaterial);
        ring.position.set(x, ceilHeight - 0.05, z);
        ceilingGroup.add(ring);
      });
    }

    scene.add(ceilingGroup);
  }

  function buildRearWall(derived) {
    const rearGroup = new THREE.Group();
    const rearZ = derived.auditoriumLength;

    // Rear acoustic wall
    const rearWallGeo = new THREE.BoxGeometry(derived.auditoriumWidth, derived.ceilingHeight, 0.3);
    const rearWall = new THREE.Mesh(rearWallGeo, acousticPanelMaterial);
    rearWall.position.set(0, derived.ceilingHeight / 2.0, rearZ);
    rearWall.receiveShadow = true;
    rearGroup.add(rearWall);

    // Projection Booth Window (Dark tinted glass port)
    const portFrameGeo = new THREE.BoxGeometry(2.6, 1.1, 0.1);
    const portFrame = new THREE.Mesh(portFrameGeo, wallTrimMaterial);
    portFrame.position.set(0, 7.2, rearZ - 0.18);
    rearGroup.add(portFrame);

    const portGlassGeo = new THREE.PlaneGeometry(2.3, 0.85);
    const portGlass = new THREE.Mesh(
      portGlassGeo,
      new THREE.MeshStandardMaterial({ color: 0x0a1018, roughness: 0.15, metalness: 0.90 })
    );
    portGlass.position.set(0, 7.2, rearZ - 0.24);
    rearGroup.add(portGlass);

    // Soft Projector Lens Glow inside the booth
    const lensLight = new THREE.PointLight(0xbdd7ff, 0.6, 6.0);
    lensLight.position.set(0, 7.2, rearZ - 0.4);
    scene.add(lensLight);

    // Atmospheric Cinema Projection Light Beam Cone
    const beamLength = rearZ - 1.0;
    const beamGeo = new THREE.ConeGeometry(3.6, beamLength, 24, 1, true);
    beamGeo.translate(0, -beamLength / 2, 0);
    beamGeo.rotateX(Math.PI / 2);

    projectionBeamMesh = new THREE.Mesh(beamGeo, projectionBeamMaterial);
    projectionBeamMesh.position.set(0, 7.2, rearZ - 0.3);
    projectionBeamMesh.lookAt(0, window.CinemaDimensions.screen.centerElevation, window.CinemaDimensions.screen.zPlane);
    scene.add(projectionBeamMesh);

    // Left and Right Emergency Exit Doors with illuminated green sign
    [-4.8, 4.8].forEach((x) => {
      // Exit door frame
      const doorGeo = new THREE.BoxGeometry(1.2, 2.6, 0.05);
      const door = new THREE.Mesh(doorGeo, wallTrimMaterial);
      door.position.set(x, 1.3, rearZ - 0.18);
      rearGroup.add(door);

      // Illuminated EXIT sign
      const signGeo = new THREE.BoxGeometry(0.40, 0.16, 0.06);
      const sign = new THREE.Mesh(signGeo, exitSignMaterial);
      sign.position.set(x, 2.8, rearZ - 0.18);
      rearGroup.add(sign);

      const exitLight = new THREE.PointLight(0x10b981, 0.18, 3.0);
      exitLight.position.set(x, 2.8, rearZ - 0.4);
      scene.add(exitLight);
    });

    scene.add(rearGroup);
  }

  // --- Photorealistic Cinema Recliners and Standard Seats ---
  // Shared geometry definitions for performance & zero memory bloat across 126 seats
  let cushionGeo, backPadGeo, backShellGeo, headrestGeo;
  let armStrutGeo, armPadGeo, cupGeo, pedestalPostGeo, baseFlangeGeo;
  let reclinerCushionGeo, reclinerFootrestGeo, reclinerBackPadGeo, reclinerHeadrestGeo;
  let reclinerArmGeo;

  function initSharedSeatGeometries() {
    // Standard Seat Shared Geometries
    const D = window.CinemaDimensions;
    const s = D.seat;
    const r = D.recliner;

    // Standard Seat Shared Geometries (Width: 0.55m, Depth: 0.52m, Height: 0.46m)
    cushionGeo = new THREE.BoxGeometry(s.width - 0.05, s.cushionThickness, s.depth - 0.02);
    backPadGeo = new THREE.BoxGeometry(s.width - 0.07, s.backrestHeight, 0.12);
    backShellGeo = new THREE.BoxGeometry(s.width - 0.06, s.backrestHeight + 0.02, 0.04);
    headrestGeo = new THREE.BoxGeometry(s.width - 0.11, 0.14, 0.14);
    armStrutGeo = new THREE.BoxGeometry(0.06, 0.28, 0.32);
    armPadGeo = new THREE.BoxGeometry(s.armrestWidth, 0.045, s.armrestLength);
    cupGeo = new THREE.CylinderGeometry(0.038, 0.032, 0.055, 12);
    pedestalPostGeo = new THREE.CylinderGeometry(0.035, 0.035, s.seatHeight - s.cushionThickness, 12);
    baseFlangeGeo = new THREE.CylinderGeometry(0.085, 0.085, 0.02, 12);

    // Recliner Shared Geometries (Rows I-L) (Width: 0.65m, Depth: 0.70m, Height: 0.48m)
    reclinerCushionGeo = new THREE.BoxGeometry(r.width - 0.07, r.cushionThickness, r.depth - 0.16);
    reclinerFootrestGeo = new THREE.BoxGeometry(r.width - 0.11, 0.08, 0.26);
    reclinerBackPadGeo = new THREE.BoxGeometry(r.width - 0.09, 0.52, 0.14);
    reclinerHeadrestGeo = new THREE.BoxGeometry(r.width - 0.15, 0.16, 0.16);
    reclinerArmGeo = new THREE.BoxGeometry(0.12, 0.34, 0.48);
  }

  function createStandardSeatMesh() {
    const D = window.CinemaDimensions;
    const s = D.seat;
    const seatGroup = new THREE.Group();
    const cushions = [];

    // 1. Contoured Cushion (top of cushion at s.seatHeight = 0.46m)
    const cushion = new THREE.Mesh(cushionGeo, velvetCrimsonMaterial);
    cushion.position.set(0, s.seatHeight - s.cushionThickness / 2.0, 0);
    cushion.castShadow = true;
    cushion.receiveShadow = true;
    seatGroup.add(cushion);
    cushions.push(cushion);

    // 2. Ergonomic Backrest (~8.5 degree tilt, total top at 0.90m)
    const backGroup = new THREE.Group();
    backGroup.position.set(0, s.seatHeight, 0.16);
    backGroup.rotation.x = THREE.MathUtils.degToRad(8.5);

    const backPad = new THREE.Mesh(backPadGeo, velvetCrimsonMaterial);
    backPad.position.set(0, s.backrestHeight / 2.0, 0);
    backPad.castShadow = true;
    backPad.receiveShadow = true;
    backGroup.add(backPad);
    cushions.push(backPad);

    const backShell = new THREE.Mesh(backShellGeo, armrestMaterial);
    backShell.position.set(0, s.backrestHeight / 2.0, 0.06);
    backShell.castShadow = true;
    backGroup.add(backShell);

    // Separate Headrest Cushion (top of headrest reaches s.totalChairHeight = 0.90m)
    const headrest = new THREE.Mesh(headrestGeo, velvetCrimsonMaterial);
    headrest.position.set(0, s.backrestHeight + 0.06, -0.01);
    headrest.castShadow = true;
    backGroup.add(headrest);
    cushions.push(headrest);

    seatGroup.add(backGroup);

    // 3. Left & Right Armrests with Cup Holders
    const armX = s.width / 2.0;
    [-armX, armX].forEach((xPos) => {
      const strut = new THREE.Mesh(armStrutGeo, armrestMaterial);
      strut.position.set(xPos, 0.40, 0.02);
      strut.castShadow = true;
      seatGroup.add(strut);

      const armPad = new THREE.Mesh(armPadGeo, armrestMaterial);
      armPad.position.set(xPos, 0.58, 0);
      armPad.castShadow = true;
      seatGroup.add(armPad);

      // Cup holder on front tip
      const cup = new THREE.Mesh(cupGeo, cupHolderMaterial);
      cup.position.set(xPos, 0.58, -0.17);
      seatGroup.add(cup);
    });

    // 4. Steel Pedestal Post & Floor Flange
    const postHeight = s.seatHeight - s.cushionThickness;
    const post = new THREE.Mesh(pedestalPostGeo, metalPedestalMaterial);
    post.position.set(0, postHeight / 2.0, 0.05);
    post.castShadow = true;
    seatGroup.add(post);

    const flange = new THREE.Mesh(baseFlangeGeo, metalPedestalMaterial);
    flange.position.set(0, 0.01, 0.05);
    seatGroup.add(flange);

    return { group: seatGroup, cushions, isRecliner: false };
  }

  function createReclinerSeatMesh() {
    const D = window.CinemaDimensions;
    const r = D.recliner;
    const seatGroup = new THREE.Group();
    const cushions = [];

    // 1. Wider Plush Cushion (top at r.seatHeight = 0.48m)
    const cushion = new THREE.Mesh(reclinerCushionGeo, reclinerMaterial);
    cushion.position.set(0, r.seatHeight - r.cushionThickness / 2.0, 0);
    cushion.castShadow = true;
    cushion.receiveShadow = true;
    seatGroup.add(cushion);
    cushions.push(cushion);

    // 2. Visible Extended Footrest
    const footrest = new THREE.Mesh(reclinerFootrestGeo, reclinerMaterial);
    footrest.position.set(0, 0.32, -0.34);
    footrest.rotation.x = THREE.MathUtils.degToRad(15);
    seatGroup.add(footrest);
    cushions.push(footrest);

    // 3. Reclined Backrest (~14 degree tilt)
    const backGroup = new THREE.Group();
    backGroup.position.set(0, r.seatHeight, 0.20);
    backGroup.rotation.x = THREE.MathUtils.degToRad(r.reclineAngleDeg);

    const backPad = new THREE.Mesh(reclinerBackPadGeo, reclinerMaterial);
    backPad.position.set(0, 0.26, 0);
    backPad.castShadow = true;
    backGroup.add(backPad);
    cushions.push(backPad);

    const headrest = new THREE.Mesh(reclinerHeadrestGeo, reclinerMaterial);
    headrest.position.set(0, 0.58, -0.01);
    headrest.castShadow = true;
    backGroup.add(headrest);
    cushions.push(headrest);

    seatGroup.add(backGroup);

    // 4. Wide Armrests with Dual Cup Holders
    const armX = r.width / 2.0;
    [-armX, armX].forEach((xPos) => {
      const arm = new THREE.Mesh(reclinerArmGeo, armrestMaterial);
      arm.position.set(xPos, 0.44, 0.02);
      arm.castShadow = true;
      seatGroup.add(arm);

      const cup = new THREE.Mesh(cupGeo, cupHolderMaterial);
      cup.position.set(xPos, 0.62, -0.18);
      seatGroup.add(cup);
    });

    return { group: seatGroup, cushions, isRecliner: true };
  }

  function buildAuditoriumSeats() {
    initSharedSeatGeometries();

    const D = window.CinemaDimensions;
    const rowLabels = D.layout.rowLabels;
    const columnXCoords = D.computeColumnXCoordinates();
    const rowZCoords = D.computeRowZDistances();

    for (let r = 0; r < rowLabels.length; r++) {
      const rowLabel = rowLabels[r];
      const isReclinerRow = r >= D.layout.standardRowCount;
      const rowZ = rowZCoords[r];
      const rowY = D.riser.rowAFloorElevation + r * D.riser.rowRise;

      for (let s = 1; s <= D.layout.seatsPerRow; s++) {
        const seatId = `${rowLabel}${s}`;
        const xPos = columnXCoords[s - 1];

        const seatData = isReclinerRow ? createReclinerSeatMesh() : createStandardSeatMesh();
        seatData.group.position.set(xPos, rowY, rowZ);
        seatData.group.name = seatId;
        scene.add(seatData.group);

        seatMeshes[seatId] = seatData;
      }
    }

    highlightSelectedSeat(activeSeatId);
  }

  function highlightSelectedSeat(seatId) {
    activeSeatId = seatId;

    Object.keys(seatMeshes).forEach((id) => {
      const data = seatMeshes[id];
      const isSelected = id === seatId;
      const defaultMat = data.isRecliner ? reclinerMaterial : velvetCrimsonMaterial;

      data.cushions.forEach((cushion) => {
        cushion.material = isSelected ? velvetMintMaterial : defaultMat;
      });
    });
  }

  // --- Screen-Driven Global Illumination (GI) Setup ---
  function setupCinematicLighting() {
    // 1. Dark Cinema Ambient Bounce (simulates dark-adapted eye in a cinema)
    const hemiLight = new THREE.HemisphereLight(0x1c1a28, 0x08080c, 0.52);
    scene.add(hemiLight);

    // 2. Primary Screen Directional Key Light (PCF Soft Shadows on seats and floor)
    screenKeyLight = new THREE.DirectionalLight(0xfbe8d8, 1.40);
    screenKeyLight.position.set(0, 4.2, 1.2);
    screenKeyLight.target.position.set(0, 1.6, 8.5);
    screenKeyLight.castShadow = true;
    screenKeyLight.shadow.mapSize.width = 1024;
    screenKeyLight.shadow.mapSize.height = 1024;
    screenKeyLight.shadow.camera.near = 0.5;
    screenKeyLight.shadow.camera.far = 28.0;
    screenKeyLight.shadow.camera.left = -8.0;
    screenKeyLight.shadow.camera.right = 8.0;
    screenKeyLight.shadow.camera.top = 9.0;
    screenKeyLight.shadow.camera.bottom = -2.0;
    screenKeyLight.shadow.bias = -0.0006;
    scene.add(screenKeyLight);
    scene.add(screenKeyLight.target);

    // 3. Screen Side Wall Diffuse Wash Lights (soft screen light spilling onto acoustic panels)
    leftWallBounceLight = new THREE.PointLight(0xf5d0b5, 0.82, 12.0);
    leftWallBounceLight.position.set(-5.2, 4.2, 2.5);
    scene.add(leftWallBounceLight);

    rightWallBounceLight = new THREE.PointLight(0xf5d0b5, 0.82, 12.0);
    rightWallBounceLight.position.set(5.2, 4.2, 2.5);
    scene.add(rightWallBounceLight);

    // 4. Ceiling Screen Diffuse Wash (illuminates front ceiling baffles)
    ceilingBounceLight = new THREE.PointLight(0xf7e2d2, 0.68, 14.0);
    ceilingBounceLight.position.set(0, 7.5, 3.5);
    scene.add(ceilingBounceLight);

    // 5. Front Stage Floor Spill Light
    const floorSpill = new THREE.PointLight(0xecd5c0, 0.50, 8.0);
    floorSpill.position.set(0, 1.2, 2.0);
    scene.add(floorSpill);

    // 6. Warm Red Aisle Step Guide Lighting
    const leftAisle = new THREE.PointLight(0xd92626, 0.65, 12.0);
    leftAisle.position.set(-2.6, 1.8, 9.0);
    scene.add(leftAisle);

    const rightAisle = new THREE.PointLight(0xd92626, 0.65, 12.0);
    rightAisle.position.set(2.6, 1.8, 9.0);
    scene.add(rightAisle);
  }

  function setupTouchControls() {
    let isDragging = false;
    let prevX = 0, prevY = 0;

    const onStart = (clientX, clientY) => {
      if (cameraState.isTransitioning) return;
      isDragging = true;
      prevX = clientX;
      prevY = clientY;
    };

    const onMove = (clientX, clientY) => {
      if (!isDragging || cameraState.isTransitioning) return;
      const dx = clientX - prevX;
      const dy = clientY - prevY;
      prevX = clientX;
      prevY = clientY;

      const sensitivity = 0.0035;
      cameraState.targetYaw = THREE.MathUtils.clamp(cameraState.targetYaw - dx * sensitivity, -MAX_YAW, MAX_YAW);
      cameraState.targetPitch = THREE.MathUtils.clamp(cameraState.targetPitch - dy * sensitivity, -MAX_PITCH, MAX_PITCH);
    };

    const onEnd = () => {
      isDragging = false;
    };

    container.addEventListener('pointerdown', (e) => onStart(e.clientX, e.clientY));
    window.addEventListener('pointermove', (e) => onMove(e.clientX, e.clientY));
    window.addEventListener('pointerup', onEnd);
    window.addEventListener('pointercancel', onEnd);

    container.addEventListener('touchstart', (e) => {
      if (e.touches.length > 0) onStart(e.touches[0].clientX, e.touches[0].clientY);
    }, { passive: true });

    window.addEventListener('touchmove', (e) => {
      if (e.touches.length > 0) onMove(e.touches[0].clientX, e.touches[0].clientY);
    }, { passive: true });

    window.addEventListener('touchend', onEnd, { passive: true });
    window.addEventListener('touchcancel', onEnd, { passive: true });
  }

  // --- Render Loop & Animation ---
  function animate(timestamp) {
    requestAnimationFrame(animate);

    const timeSec = timestamp * 0.001;

    // Subtle 24fps Film Projection Breathing / Light Flicker
    if (screenKeyLight) {
      const flicker = 1.0 + Math.sin(timeSec * 2.1) * 0.025 + Math.sin(timeSec * 5.4) * 0.015;
      screenKeyLight.intensity = 1.40 * flicker;
      if (leftWallBounceLight) leftWallBounceLight.intensity = 0.82 * flicker;
      if (rightWallBounceLight) rightWallBounceLight.intensity = 0.82 * flicker;
      if (ceilingBounceLight) ceilingBounceLight.intensity = 0.68 * flicker;
    }

    if (cameraState.isTransitioning) {
      const elapsed = timestamp - cameraState.transitionStartTime;
      const progress = Math.min(elapsed / cameraState.transitionDuration, 1.0);
      const ease = 0.5 - Math.cos(progress * Math.PI) / 2; // easeInOut

      if (cameraState.transitionType === 'forward') {
        if (!cameraState.hasEnteredOverview) {
          // First Entrance: Stage 1 (0% - 35%) hold overhead; Stage 2 (35% - 100%) descent
          if (progress < 0.35) {
            cameraState.currentPos.copy(cameraState.overheadPos);
            cameraState.currentLook.copy(cameraState.overheadLook);
          } else {
            const t2 = (progress - 0.35) / 0.65;
            const curveEase = 1.0 - Math.pow(1.0 - t2, 3);
            const arcHeight = Math.sin(t2 * Math.PI) * 0.8;

            cameraState.currentPos.lerpVectors(cameraState.overheadPos, cameraState.targetEyePos, curveEase);
            cameraState.currentPos.y += arcHeight;
            cameraState.currentLook.lerpVectors(cameraState.overheadLook, cameraState.targetLook, curveEase);
          }
        } else {
          // Direct smooth transition between seats
          cameraState.currentPos.lerpVectors(cameraState.startPos, cameraState.targetEyePos, ease);
          cameraState.currentLook.lerpVectors(cameraState.startLook, cameraState.targetLook, ease);
        }
      } else {
        // Reverse Transition back to overhead view
        cameraState.currentPos.lerpVectors(cameraState.targetEyePos, cameraState.overheadPos, ease);
        cameraState.currentLook.lerpVectors(cameraState.targetLook, cameraState.overheadLook, ease);
      }

      cameraState.yaw *= (1.0 - ease);
      cameraState.pitch *= (1.0 - ease);

      if (progress >= 1.0) {
        cameraState.isTransitioning = false;
        if (cameraState.transitionType === 'forward') {
          cameraState.hasEnteredOverview = true;
          sendToFlutter({ type: 'transitionCompleted', seatId: activeSeatId });
        } else {
          cameraState.hasEnteredOverview = false;
          sendToFlutter({ type: 'reverseTransitionCompleted' });
        }
      }
    } else {
      cameraState.yaw += (cameraState.targetYaw - cameraState.yaw) * 0.18;
      cameraState.pitch += (cameraState.targetPitch - cameraState.pitch) * 0.18;
    }

    camera.position.copy(cameraState.currentPos);
    camera.lookAt(cameraState.currentLook);
    camera.rotateY(cameraState.yaw);
    camera.rotateX(cameraState.pitch);
    renderer.render(scene, camera);
  }

  function onWindowResize() {
    if (!renderer || !camera) return;
    const width = window.innerWidth;
    const height = window.innerHeight;
    camera.aspect = width / height;

    if (camera.aspect > 1.0 || isFullscreenLandscape) {
      // Landscape widescreen mode: cinema screen occupies the majority of the display
      camera.fov = 42.0;
    } else {
      // Standard portrait POV mode
      camera.fov = 58.0;
    }
    camera.updateProjectionMatrix();
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2.0));
  }

  function sendToFlutter(data) {
    let attempts = 0;
    function trySend() {
      try {
        if (window.FlutterBridge && window.FlutterBridge.postMessage) {
          window.FlutterBridge.postMessage(JSON.stringify(data));
        } else if (attempts < 30) {
          attempts++;
          setTimeout(trySend, 80);
        }
      } catch (e) {
        console.warn('FlutterBridge error:', e);
      }
    }
    trySend();
  }

  window.SeatView3D = {
    notifyReady: function () {
      if (!isInitialized) {
        init();
      }
      const validation = window.CinemaDimensions ? window.CinemaDimensions.validateAuditorium() : null;
      sendToFlutter({ type: 'sceneReady', validation: validation });
    },
    dispatch: function (messageStr) {
      try {
        const msg = typeof messageStr === 'string' ? JSON.parse(messageStr) : messageStr;
        handleCommand(msg);
      } catch (err) {
        console.error('Error in SeatView3D.dispatch:', err);
      }
    },
  };

  function handleCommand(msg) {
    if (!msg || !msg.type) return;

    switch (msg.type) {
      case 'startTwoStageTransition':
      case 'setCameraPose':
      case 'selectSeat': {
        if (msg.seatId) {
          highlightSelectedSeat(msg.seatId);
        }

        if (msg.cameraPosition && msg.lookAtTarget) {
          const D = window.CinemaDimensions;
          cameraState.targetEyePos.set(msg.cameraPosition.x, msg.cameraPosition.y, msg.cameraPosition.z);
          cameraState.targetLook.set(
            msg.lookAtTarget.x,
            D ? D.screen.centerElevation : 4.30,
            msg.lookAtTarget.z || (D ? D.screen.zPlane : 0.5)
          );

          if (camera && msg.fov && !isFullscreenLandscape) {
            camera.fov = msg.fov;
            camera.updateProjectionMatrix();
          }
        }

        cameraState.startPos.copy(cameraState.currentPos);
        cameraState.startLook.copy(cameraState.currentLook);
        cameraState.transitionStartTime = performance.now();
        cameraState.transitionDuration = msg.durationMs || 1200;
        cameraState.transitionType = 'forward';
        cameraState.isTransitioning = true;
        break;
      }

      case 'reverseTransition': {
        cameraState.transitionStartTime = performance.now();
        cameraState.transitionDuration = msg.durationMs || 800;
        cameraState.transitionType = 'reverse';
        cameraState.isTransitioning = true;
        break;
      }

      case 'recenterCamera': {
        cameraState.targetYaw = 0.0;
        cameraState.targetPitch = 0.0;
        break;
      }

      case 'setFullscreen': {
        isFullscreenLandscape = !!msg.isFullScreen;
        onWindowResize();
        break;
      }

      case 'resize': {
        onWindowResize();
        break;
      }

      case 'setLookInput': {
        if (!cameraState.isTransitioning) {
          const sensitivity = 0.0035;
          cameraState.targetYaw = THREE.MathUtils.clamp(cameraState.targetYaw - msg.deltaX * sensitivity, -MAX_YAW, MAX_YAW);
          cameraState.targetPitch = THREE.MathUtils.clamp(cameraState.targetPitch - msg.deltaY * sensitivity, -MAX_PITCH, MAX_PITCH);
        }
        break;
      }
    }
  }
})();
