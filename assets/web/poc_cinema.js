/**
 * Seat View — True 3D Cinema Renderer (Proof of Concept)
 * Built with Three.js r128 (Bundled locally)
 */

(function () {
  'use strict';

  // --- Global State ---
  let scene, camera, renderer;
  let container;
  let screenMesh;
  let animId = null;

  // Camera coordinates & state
  const cameraState = {
    currentPos: new THREE.Vector3(0, 1.65, 8.5),
    targetPos: new THREE.Vector3(0, 1.65, 8.5),
    currentLook: new THREE.Vector3(0, 3.5, 0),
    targetLook: new THREE.Vector3(0, 3.5, 0),
    yaw: 0.0,
    pitch: 0.0,
    targetYaw: 0.0,
    targetPitch: 0.0,
    isTransitioning: false,
    transitionStartPos: new THREE.Vector3(),
    transitionEndPos: new THREE.Vector3(),
    transitionStartLook: new THREE.Vector3(),
    transitionEndLook: new THREE.Vector3(),
    transitionProgress: 1.0,
    transitionDuration: 600, // ms
    transitionStartTime: 0,
  };

  // Limits for look-around
  const MAX_YAW = 0.65; // ~37 degrees
  const MAX_PITCH = 0.45; // ~26 degrees

  // Materials Cache
  let velvetRedMaterial, darkPlasticMaterial, metalPedestalMaterial;
  let floorMaterial, wallMaterial, ceilingMaterial, stepLightMaterial;

  // Initialize when DOM is ready
  window.addEventListener('DOMContentLoaded', init);

  function init() {
    container = document.getElementById('canvas-container');

    // 1. Scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0x060608);
    scene.fog = new THREE.FogExp2(0x060608, 0.025);

    // 2. Camera (Perspective)
    const aspect = window.innerWidth / window.innerHeight;
    camera = new THREE.PerspectiveCamera(60, aspect, 0.1, 100.0);
    camera.position.copy(cameraState.currentPos);
    camera.lookAt(cameraState.currentLook);

    // 3. Renderer (WebGL with Shadow Map and Tone Mapping)
    renderer = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'high-performance' });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2.0));
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.05;
    container.appendChild(renderer.domElement);

    // 4. Create Materials
    initMaterials();

    // 5. Build Environment (Screen, Floor, Walls, Ceiling)
    buildAuditoriumEnvironment();

    // 6. Build Realistic 3D Cinema Seats
    buildCinemaSeats();

    // 7. Setup Lighting
    setupLighting();

    // 8. Event Listeners
    window.addEventListener('resize', onWindowResize);
    setupTouchControls();

    // 9. Hide Loading
    const loadingElem = document.getElementById('loading-indicator');
    if (loadingElem) {
      loadingElem.style.opacity = '0';
      setTimeout(() => loadingElem.remove(), 400);
    }

    // 10. Start Render Loop
    animate(0);

    // Notify Flutter that the scene is loaded and ready
    sendToFlutter({
      type: 'sceneReady',
      renderer: 'threejs',
      version: 'r128',
      initialCamera: {
        x: cameraState.currentPos.x,
        y: cameraState.currentPos.y,
        z: cameraState.currentPos.z,
      },
    });
  }

  // --- Materials ---
  function initMaterials() {
    // Red Cinema Velvet (PBR)
    velvetRedMaterial = new THREE.MeshStandardMaterial({
      color: 0x8b1220,
      roughness: 0.85,
      metalness: 0.04,
    });

    // Dark charcoal shell/back & armrest core
    darkPlasticMaterial = new THREE.MeshStandardMaterial({
      color: 0x141416,
      roughness: 0.6,
      metalness: 0.1,
    });

    // Cast metal pedestal & cup holder rim
    metalPedestalMaterial = new THREE.MeshStandardMaterial({
      color: 0x222226,
      roughness: 0.35,
      metalness: 0.85,
    });

    // Tiered Carpet Floor
    floorMaterial = new THREE.MeshStandardMaterial({
      color: 0x101014,
      roughness: 0.95,
      metalness: 0.02,
    });

    // Acoustic Slatted Wall
    wallMaterial = new THREE.MeshStandardMaterial({
      color: 0x18141c,
      roughness: 0.88,
      metalness: 0.05,
    });

    // Dark Ceiling
    ceilingMaterial = new THREE.MeshStandardMaterial({
      color: 0x0c0c0e,
      roughness: 0.9,
    });

    // Step LED Strip (warm amber emissive)
    stepLightMaterial = new THREE.MeshBasicMaterial({
      color: 0xffa030,
    });
  }

  // --- Auditorium Environment ---
  function buildAuditoriumEnvironment() {
    // 1. Curved Cinema Screen
    // Parametric curved cylinder slice
    const screenRadius = 24.0;
    const screenWidthAngle = 0.52; // ~30 degrees arc
    const screenHeight = 6.2;
    const screenCenterZ = 0.0;
    const screenCenterY = 3.8;

    const screenGeometry = new THREE.CylinderGeometry(
      screenRadius,
      screenRadius,
      screenHeight,
      32,
      1,
      true,
      Math.PI * 1.5 - screenWidthAngle / 2,
      screenWidthAngle
    );

    // Create Screen Image Canvas Texture (Cinematic Sci-Fi visual)
    const screenTexture = createScreenTexture();

    const screenMaterial = new THREE.MeshBasicMaterial({
      map: screenTexture,
      side: THREE.BackSide,
    });

    screenMesh = new THREE.Mesh(screenGeometry, screenMaterial);
    screenMesh.position.set(0, screenCenterY, screenCenterZ - screenRadius + 1.2);
    screenMesh.rotation.y = Math.PI;
    scene.add(screenMesh);

    // Outer Screen Bezel / Frame
    const frameGeometry = new THREE.CylinderGeometry(
      screenRadius + 0.05,
      screenRadius + 0.05,
      screenHeight + 0.35,
      32,
      1,
      true,
      Math.PI * 1.5 - (screenWidthAngle + 0.03) / 2,
      screenWidthAngle + 0.03
    );
    const frameMaterial = new THREE.MeshStandardMaterial({
      color: 0x08080a,
      roughness: 0.7,
      side: THREE.BackSide,
    });
    const frameMesh = new THREE.Mesh(frameGeometry, frameMaterial);
    frameMesh.position.copy(screenMesh.position);
    frameMesh.rotation.y = Math.PI;
    scene.add(frameMesh);

    // 2. Stepped Auditorium Floor (Tiers)
    const numRows = 8;
    for (let r = 0; r < numRows; r++) {
      const rowZ = 6.0 + r * 1.5;
      const rowY = 0.5 + r * 0.42;

      // Platform for this row
      const stepGeo = new THREE.BoxGeometry(14.0, 0.42, 1.5);
      const stepMesh = new THREE.Mesh(stepGeo, floorMaterial);
      stepMesh.position.set(0, rowY - 0.21, rowZ);
      stepMesh.receiveShadow = true;
      scene.add(stepMesh);

      // Warm Amber Step LED Light Strip on riser
      const ledGeo = new THREE.BoxGeometry(13.8, 0.02, 0.03);
      const ledMesh = new THREE.Mesh(ledGeo, stepLightMaterial);
      ledMesh.position.set(0, rowY - 0.01, rowZ - 0.75);
      scene.add(ledMesh);
    }

    // Front Floor Extension
    const frontFloorGeo = new THREE.BoxGeometry(14.0, 0.5, 6.0);
    const frontFloor = new THREE.Mesh(frontFloorGeo, floorMaterial);
    frontFloor.position.set(0, 0.25, 3.0);
    frontFloor.receiveShadow = true;
    scene.add(frontFloor);

    // 3. Acoustic Side Walls
    const wallGeo = new THREE.BoxGeometry(0.3, 10.0, 22.0);
    const leftWall = new THREE.Mesh(wallGeo, wallMaterial);
    leftWall.position.set(-6.9, 4.5, 9.0);
    scene.add(leftWall);

    const rightWall = new THREE.Mesh(wallGeo, wallMaterial);
    rightWall.position.set(6.9, 4.5, 9.0);
    scene.add(rightWall);

    // 4. Ceiling
    const ceilingGeo = new THREE.BoxGeometry(14.0, 0.3, 22.0);
    const ceiling = new THREE.Mesh(ceilingGeo, ceilingMaterial);
    ceiling.position.set(0, 9.5, 9.0);
    scene.add(ceiling);
  }

  // Procedural Cinematic Screen Canvas
  function createScreenTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 1024;
    canvas.height = 450;
    const ctx = canvas.getContext('2d');

    // Deep space gradient
    const grad = ctx.createLinearGradient(0, 0, 1024, 450);
    grad.addColorStop(0, '#040b17');
    grad.addColorStop(0.5, '#1e0c2b');
    grad.addColorStop(1, '#081729');
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, 1024, 450);

    // Cosmic nebula / cinematic glow
    const radial = ctx.createRadialGradient(512, 225, 20, 512, 225, 420);
    radial.addColorStop(0, 'rgba(235, 175, 75, 0.75)');
    radial.addColorStop(0.35, 'rgba(180, 50, 100, 0.45)');
    radial.addColorStop(0.7, 'rgba(30, 20, 60, 0.2)');
    radial.addColorStop(1, 'rgba(0, 0, 0, 0)');
    ctx.fillStyle = radial;
    ctx.fillRect(0, 0, 1024, 450);

    // Anamorphic horizontal lens flare
    const flare = ctx.createLinearGradient(0, 225, 1024, 225);
    flare.addColorStop(0, 'rgba(100, 180, 255, 0)');
    flare.addColorStop(0.48, 'rgba(200, 240, 255, 0.8)');
    flare.addColorStop(0.5, 'rgba(255, 255, 255, 0.95)');
    flare.addColorStop(0.52, 'rgba(200, 240, 255, 0.8)');
    flare.addColorStop(1, 'rgba(100, 180, 255, 0)');
    ctx.fillStyle = flare;
    ctx.fillRect(0, 220, 1024, 10);

    // Title Typography
    ctx.font = 'bold 38px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillStyle = '#ffffff';
    ctx.textAlign = 'center';
    ctx.letterSpacing = '6px';
    ctx.fillText('SEAT VIEW CINEMA', 512, 215);

    ctx.font = '600 16px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillStyle = '#e5a93c';
    ctx.fillText('FIRST-PERSON 3D AUDITORIUM EXPERIENCE', 512, 255);

    const texture = new THREE.CanvasTexture(canvas);
    texture.minFilter = THREE.LinearFilter;
    texture.magFilter = THREE.LinearFilter;
    return texture;
  }

  // --- Realistic 3D Cinema Seat Builder ---
  function createCinemaSeatMesh() {
    const seatGroup = new THREE.Group();

    // 1. Seat Base Cushion (Plush padded cushion with rounded beveled contour)
    const cushionGeo = new THREE.BoxGeometry(0.52, 0.12, 0.5);
    const cushionMesh = new THREE.Mesh(cushionGeo, velvetRedMaterial);
    cushionMesh.position.set(0, 0.42, 0);
    cushionMesh.castShadow = true;
    cushionMesh.receiveShadow = true;
    seatGroup.add(cushionMesh);

    // Cushion Front Lip (curved roll-off)
    const lipGeo = new THREE.CylinderGeometry(0.06, 0.06, 0.52, 16);
    const lipMesh = new THREE.Mesh(lipGeo, velvetRedMaterial);
    lipMesh.rotation.z = Math.PI / 2;
    lipMesh.position.set(0, 0.41, -0.25);
    lipMesh.castShadow = true;
    seatGroup.add(lipMesh);

    // 2. Seat Backrest (Curved, ergonomic tilt ~9 degrees)
    const backGroup = new THREE.Group();
    backGroup.position.set(0, 0.45, 0.22);
    backGroup.rotation.x = THREE.MathUtils.degToRad(9);

    // Backrest Main Velvet Pad
    const backPadGeo = new THREE.BoxGeometry(0.50, 0.62, 0.13);
    const backPad = new THREE.Mesh(backPadGeo, velvetRedMaterial);
    backPad.position.set(0, 0.31, 0);
    backPad.castShadow = true;
    backPad.receiveShadow = true;
    backGroup.add(backPad);

    // Backrest Protective Outer Shell (Dark molded polymer)
    const backShellGeo = new THREE.BoxGeometry(0.51, 0.63, 0.04);
    const backShell = new THREE.Mesh(backShellGeo, darkPlasticMaterial);
    backShell.position.set(0, 0.31, 0.075);
    backShell.castShadow = true;
    backGroup.add(backShell);

    // 3. Headrest (Contoured top support)
    const headrestGeo = new THREE.BoxGeometry(0.44, 0.18, 0.14);
    const headrest = new THREE.Mesh(headrestGeo, velvetRedMaterial);
    headrest.position.set(0, 0.67, -0.01);
    headrest.castShadow = true;
    backGroup.add(headrest);

    seatGroup.add(backGroup);

    // 4. Armrests (Left & Right) with Cup Holders
    const armrestPositions = [-0.30, 0.30];
    armrestPositions.forEach((xPos) => {
      // Armrest Base / Support Strut
      const strutGeo = new THREE.BoxGeometry(0.06, 0.35, 0.38);
      const strut = new THREE.Mesh(strutGeo, darkPlasticMaterial);
      strut.position.set(xPos, 0.45, 0.02);
      strut.castShadow = true;
      seatGroup.add(strut);

      // Top Padded Armrest
      const armPadGeo = new THREE.BoxGeometry(0.09, 0.05, 0.42);
      const armPad = new THREE.Mesh(armPadGeo, darkPlasticMaterial);
      armPad.position.set(xPos, 0.64, 0);
      armPad.castShadow = true;
      seatGroup.add(armPad);

      // Integrated Cup Holder
      const cupGeo = new THREE.CylinderGeometry(0.042, 0.038, 0.07, 16);
      const cup = new THREE.Mesh(cupGeo, metalPedestalMaterial);
      cup.position.set(xPos, 0.64, -0.2);
      seatGroup.add(cup);
    });

    // 5. Heavy Steel Center Pedestal & Floor Mounting Plate
    const postGeo = new THREE.CylinderGeometry(0.04, 0.04, 0.35, 12);
    const post = new THREE.Mesh(postGeo, metalPedestalMaterial);
    post.position.set(0, 0.18, 0.05);
    post.castShadow = true;
    seatGroup.add(post);

    const plateGeo = new THREE.BoxGeometry(0.24, 0.02, 0.28);
    const plate = new THREE.Mesh(plateGeo, metalPedestalMaterial);
    plate.position.set(0, 0.01, 0.05);
    plate.receiveShadow = true;
    seatGroup.add(plate);

    return seatGroup;
  }

  // Populate Cinema Auditorium with Realistic Seats
  function buildCinemaSeats() {
    // 8 Rows, 8 Seats Per Row (Same layout as MockAuditoriums)
    const xOffsets = [-4.5, -3.2, -1.9, -0.8, 0.8, 1.9, 3.2, 4.5];
    const rowLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    for (let r = 0; r < rowLabels.length; r++) {
      const rowY = 0.5 + r * 0.42;
      const rowZ = 6.0 + r * 1.5;

      for (let s = 0; s < xOffsets.length; s++) {
        const seat = createCinemaSeatMesh();
        seat.position.set(xOffsets[s], rowY, rowZ);
        seat.name = `${rowLabels[r]}${s + 1}`;
        scene.add(seat);
      }
    }
  }

  // --- Lighting & Atmosphere ---
  function setupLighting() {
    // 1. Cinema Ambient (Very low blue/indigo fill)
    const ambientLight = new THREE.AmbientLight(0x181824, 0.65);
    scene.add(ambientLight);

    // 2. Main Screen Emissive Spill Light (Directional, angled back into seats)
    const screenLight = new THREE.DirectionalLight(0xf5e8df, 1.25);
    screenLight.position.set(0, 4.5, 0.5);
    screenLight.target.position.set(0, 2.0, 11.0);
    screenLight.castShadow = true;
    screenLight.shadow.mapSize.width = 1024;
    screenLight.shadow.mapSize.height = 1024;
    screenLight.shadow.camera.near = 0.5;
    screenLight.shadow.camera.far = 25.0;
    screenLight.shadow.camera.left = -7.0;
    screenLight.shadow.camera.right = 7.0;
    screenLight.shadow.camera.top = 8.0;
    screenLight.shadow.camera.bottom = -2.0;
    screenLight.shadow.bias = -0.0008;
    scene.add(screenLight);
    scene.add(screenLight.target);

    // 3. Subtle Cinema Wall Sconces / Aisle Fill
    const leftFill = new THREE.PointLight(0xffa244, 0.45, 12.0);
    leftFill.position.set(-6.5, 3.5, 10.0);
    scene.add(leftFill);

    const rightFill = new THREE.PointLight(0xffa244, 0.45, 12.0);
    rightFill.position.set(6.5, 3.5, 10.0);
    scene.add(rightFill);
  }

  // --- Touch & Pointer Look-Around Controls ---
  function setupTouchControls() {
    let isDragging = false;
    let prevX = 0;
    let prevY = 0;

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

      // Sensitivity
      const sensitivity = 0.0035;
      cameraState.targetYaw = THREE.MathUtils.clamp(
        cameraState.targetYaw - dx * sensitivity,
        -MAX_YAW,
        MAX_YAW
      );
      cameraState.targetPitch = THREE.MathUtils.clamp(
        cameraState.targetPitch - dy * sensitivity,
        -MAX_PITCH,
        MAX_PITCH
      );
    };

    const onEnd = () => {
      isDragging = false;
    };

    container.addEventListener('mousedown', (e) => onStart(e.clientX, e.clientY));
    window.addEventListener('mousemove', (e) => onMove(e.clientX, e.clientY));
    window.addEventListener('mouseup', onEnd);

    container.addEventListener(
      'touchstart',
      (e) => {
        if (e.touches.length === 1) onStart(e.touches[0].clientX, e.touches[0].clientY);
      },
      { passive: true }
    );
    window.addEventListener(
      'touchmove',
      (e) => {
        if (e.touches.length === 1) onMove(e.touches[0].clientX, e.touches[0].clientY);
      },
      { passive: true }
    );
    window.addEventListener('touchend', onEnd);
  }

  // --- Animation Loop ---
  function animate(timestamp) {
    animId = requestAnimationFrame(animate);

    // Camera Transition Interpolation (Cubic Ease Out)
    if (cameraState.isTransitioning) {
      const elapsed = timestamp - cameraState.transitionStartTime;
      const progress = Math.min(elapsed / cameraState.transitionDuration, 1.0);
      const ease = 1.0 - Math.pow(1.0 - progress, 3); // easeOutCubic

      cameraState.currentPos.lerpVectors(
        cameraState.transitionStartPos,
        cameraState.transitionEndPos,
        ease
      );
      cameraState.currentLook.lerpVectors(
        cameraState.transitionStartLook,
        cameraState.transitionEndLook,
        ease
      );

      // Smoothly return look-around offsets to 0 during seat switch
      cameraState.yaw *= 1.0 - ease;
      cameraState.pitch *= 1.0 - ease;
      cameraState.targetYaw = 0.0;
      cameraState.targetPitch = 0.0;

      if (progress >= 1.0) {
        cameraState.isTransitioning = false;
        sendToFlutter({ type: 'cameraTransitionCompleted' });
      }
    } else {
      // Smooth look-around lerp
      cameraState.yaw += (cameraState.targetYaw - cameraState.yaw) * 0.18;
      cameraState.pitch += (cameraState.targetPitch - cameraState.pitch) * 0.18;
    }

    // Apply Position & Look-at with Yaw/Pitch Offsets
    camera.position.copy(cameraState.currentPos);

    // Compute effective look target
    const forward = new THREE.Vector3().subVectors(cameraState.currentLook, cameraState.currentPos);
    const dist = forward.length();

    const baseYaw = Math.atan2(forward.x, -forward.z);
    const basePitch = Math.asin(THREE.MathUtils.clamp(forward.y / (dist > 0.001 ? dist : 1.0), -1.0, 1.0));

    const totalYaw = baseYaw + cameraState.yaw;
    const totalPitch = THREE.MathUtils.clamp(basePitch + cameraState.pitch, -1.1, 1.1);

    const effX = cameraState.currentPos.x + dist * Math.sin(totalYaw) * Math.cos(totalPitch);
    const effY = cameraState.currentPos.y + dist * Math.sin(totalPitch);
    const effZ = cameraState.currentPos.z - dist * Math.cos(totalYaw) * Math.cos(totalPitch);

    camera.lookAt(effX, effY, effZ);

    renderer.render(scene, camera);
  }

  function onWindowResize() {
    if (!renderer || !camera) return;
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  }

  // --- Flutter Communication Bridge ---
  function sendToFlutter(data) {
    try {
      const json = JSON.stringify(data);
      if (window.FlutterBridge && window.FlutterBridge.postMessage) {
        window.FlutterBridge.postMessage(json);
      }
    } catch (e) {
      console.warn('FlutterBridge not available:', e);
    }
  }

  // Exposed API to Flutter via runJavaScript
  window.SeatView3D = {
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
      case 'setCameraPose':
      case 'selectSeat': {
        const duration = msg.durationMs || 500;
        const targetPos = new THREE.Vector3(
          msg.cameraPosition.x,
          msg.cameraPosition.y,
          msg.cameraPosition.z
        );
        const targetLook = new THREE.Vector3(
          msg.lookAtTarget.x,
          msg.lookAtTarget.y,
          msg.lookAtTarget.z
        );

        cameraState.transitionStartPos.copy(cameraState.currentPos);
        cameraState.transitionEndPos.copy(targetPos);
        cameraState.transitionStartLook.copy(cameraState.currentLook);
        cameraState.transitionEndLook.copy(targetLook);
        cameraState.transitionStartTime = performance.now();
        cameraState.transitionDuration = duration;
        cameraState.isTransitioning = true;
        break;
      }

      case 'recenterCamera': {
        cameraState.targetYaw = 0.0;
        cameraState.targetPitch = 0.0;
        break;
      }

      case 'setLookInput': {
        if (!cameraState.isTransitioning) {
          const sensitivity = 0.0035;
          cameraState.targetYaw = THREE.MathUtils.clamp(
            cameraState.targetYaw - msg.deltaX * sensitivity,
            -MAX_YAW,
            MAX_YAW
          );
          cameraState.targetPitch = THREE.MathUtils.clamp(
            cameraState.targetPitch - msg.deltaY * sensitivity,
            -MAX_PITCH,
            MAX_PITCH
          );
        }
        break;
      }

      default:
        console.warn('Unknown command type:', msg.type);
    }
  }
})();
