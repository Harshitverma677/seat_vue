/**
 * Seat View — Full 126-Seat 3D Cinema Renderer (WebGL / Three.js r128)
 * 9 Rows (A-I), 14 Seats Per Row, Rows A-H Standard, Row I Recliner
 * Implements two-stage camera choreography (Overhead 0-35% -> Eye level 35-100%)
 */

(function () {
  'use strict';

  // --- Global Scene Handles ---
  let scene, camera, renderer, container;
  let screenMesh;
  let seatMeshes = {}; // Map of seatId -> { group, cushions: [], isRecliner }
  let activeSeatId = 'I12';

  // Camera State & Choreography
  const cameraState = {
    currentPos: new THREE.Vector3(0, 9.5, 18.5), // Starts at overhead view
    currentLook: new THREE.Vector3(0, 3.2, 0),
    overheadPos: new THREE.Vector3(0, 9.5, 18.5),
    overheadLook: new THREE.Vector3(0, 3.2, 0),
    targetEyePos: new THREE.Vector3(0, 1.65, 8.5),
    targetLook: new THREE.Vector3(0, 3.5, 0),
    yaw: 0.0,
    pitch: 0.0,
    targetYaw: 0.0,
    targetPitch: 0.0,
    isTransitioning: false,
    transitionType: 'forward', // 'forward' | 'reverse'
    transitionStartTime: 0,
    transitionDuration: 1200, // 1200 ms total
  };

  const MAX_YAW = 0.65;
  const MAX_PITCH = 0.45;

  // Materials Cache
  let velvetCrimsonMaterial, velvetMintMaterial;
  let darkPlasticMaterial, metalPedestalMaterial;
  let reclinerMaterial, floorMaterial, wallMaterial, ceilingMaterial;
  let redAisleLightMaterial, screenMaterial;

  window.addEventListener('DOMContentLoaded', init);

  function init() {
    container = document.getElementById('canvas-container');

    // 1. Scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0x0a0a0c);
    scene.fog = new THREE.FogExp2(0x0a0a0c, 0.022);

    // 2. Camera
    const aspect = window.innerWidth / window.innerHeight;
    camera = new THREE.PerspectiveCamera(60, aspect, 0.1, 100.0);
    camera.position.copy(cameraState.currentPos);
    camera.lookAt(cameraState.currentLook);

    // 3. WebGL Renderer
    renderer = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'high-performance' });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2.0));
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.05;
    container.appendChild(renderer.domElement);

    // 4. Materials
    initMaterials();

    // 5. Build Environment
    buildEnvironment();

    // 6. Build All 126 Seats (9 Rows x 14 Columns)
    buildAuditoriumSeats();

    // 7. Lighting
    setupLighting();

    // 8. Event Listeners
    window.addEventListener('resize', onWindowResize);
    setupTouchControls();

    // 9. Hide Loading
    const loadingElem = document.getElementById('loading-indicator');
    if (loadingElem) {
      loadingElem.style.opacity = '0';
      setTimeout(() => loadingElem.remove(), 350);
    }

    // 10. Start Render Loop
    animate(0);

    sendToFlutter({ type: 'sceneReady' });
  }

  function initMaterials() {
    // Theater Seat Crimson Red (#B91C1C)
    velvetCrimsonMaterial = new THREE.MeshStandardMaterial({
      color: 0xb91c1c,
      roughness: 0.82,
      metalness: 0.04,
    });

    // Selected Seat Mint Green (#4ADE80)
    velvetMintMaterial = new THREE.MeshStandardMaterial({
      color: 0x4ade80,
      roughness: 0.75,
      metalness: 0.05,
      emissive: 0x14532d,
      emissiveIntensity: 0.35,
    });

    // Recliner Fill (#2A1C1E)
    reclinerMaterial = new THREE.MeshStandardMaterial({
      color: 0x2a1c1e,
      roughness: 0.78,
      metalness: 0.08,
    });

    darkPlasticMaterial = new THREE.MeshStandardMaterial({
      color: 0x141416,
      roughness: 0.65,
      metalness: 0.12,
    });

    metalPedestalMaterial = new THREE.MeshStandardMaterial({
      color: 0x222226,
      roughness: 0.35,
      metalness: 0.85,
    });

    floorMaterial = new THREE.MeshStandardMaterial({
      color: 0x101014,
      roughness: 0.95,
      metalness: 0.02,
    });

    wallMaterial = new THREE.MeshStandardMaterial({
      color: 0x16161c,
      roughness: 0.88,
      metalness: 0.05,
    });

    ceilingMaterial = new THREE.MeshStandardMaterial({
      color: 0x0c0c0e,
      roughness: 0.9,
    });

    // Red Aisle Guide Lighting (#B91C1C soft emissive)
    redAisleLightMaterial = new THREE.MeshBasicMaterial({
      color: 0xb91c1c,
    });
  }

  function buildEnvironment() {
    // 1. Curved Screen
    const screenRadius = 24.0;
    const screenWidthAngle = 0.54; // ~31 degrees
    const screenHeight = 6.4;
    const screenCenterY = 3.8;

    const screenGeometry = new THREE.CylinderGeometry(
      screenRadius,
      screenRadius,
      screenHeight,
      36,
      1,
      true,
      Math.PI * 1.5 - screenWidthAngle / 2,
      screenWidthAngle
    );

    const screenTexture = createScreenTexture();
    screenMaterial = new THREE.MeshBasicMaterial({
      map: screenTexture,
      side: THREE.BackSide,
    });

    screenMesh = new THREE.Mesh(screenGeometry, screenMaterial);
    screenMesh.position.set(0, screenCenterY, 0.0 - screenRadius + 1.2);
    screenMesh.rotation.y = Math.PI;
    scene.add(screenMesh);

    // Screen Outer Bezel
    const frameGeometry = new THREE.CylinderGeometry(
      screenRadius + 0.05,
      screenRadius + 0.05,
      screenHeight + 0.35,
      36,
      1,
      true,
      Math.PI * 1.5 - (screenWidthAngle + 0.025) / 2,
      screenWidthAngle + 0.025
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

    // 2. Tiered Auditorium Floor
    for (let r = 0; r < 9; r++) {
      const rowZ = 5.42 + r * 0.875 + (r === 8 ? 0.88 : 0.0);
      const rowY = 0.5 + r * 0.38;

      const stepGeo = new THREE.BoxGeometry(16.0, 0.38, 1.4);
      const stepMesh = new THREE.Mesh(stepGeo, floorMaterial);
      stepMesh.position.set(0, rowY - 0.19, rowZ);
      stepMesh.receiveShadow = true;
      scene.add(stepMesh);

      // Red Aisle Guide Light Strip on Riser
      const redLightGeo = new THREE.BoxGeometry(15.8, 0.025, 0.03);
      const redLightMesh = new THREE.Mesh(redLightGeo, redAisleLightMaterial);
      redLightMesh.position.set(0, rowY - 0.01, rowZ - 0.7);
      scene.add(redLightMesh);
    }

    // Front Floor Extension
    const frontFloorGeo = new THREE.BoxGeometry(16.0, 0.5, 6.0);
    const frontFloor = new THREE.Mesh(frontFloorGeo, floorMaterial);
    frontFloor.position.set(0, 0.25, 2.7);
    frontFloor.receiveShadow = true;
    scene.add(frontFloor);

    // 3. Acoustic Walls & Ceiling
    const wallGeo = new THREE.BoxGeometry(0.3, 11.0, 24.0);
    const leftWall = new THREE.Mesh(wallGeo, wallMaterial);
    leftWall.position.set(-8.0, 5.0, 10.0);
    scene.add(leftWall);

    const rightWall = new THREE.Mesh(wallGeo, wallMaterial);
    rightWall.position.set(8.0, 5.0, 10.0);
    scene.add(rightWall);

    const ceilingGeo = new THREE.BoxGeometry(16.0, 0.3, 24.0);
    const ceiling = new THREE.Mesh(ceilingGeo, ceilingMaterial);
    ceiling.position.set(0, 10.5, 10.0);
    scene.add(ceiling);
  }

  function createScreenTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 1024;
    canvas.height = 450;
    const ctx = canvas.getContext('2d');

    // Desert Dune warm golden horizon
    const skyGrad = ctx.createLinearGradient(0, 0, 0, 280);
    skyGrad.addColorStop(0, '#75543c');
    skyGrad.addColorStop(0.6, '#b6906a');
    skyGrad.addColorStop(1, '#dfba8e');
    ctx.fillStyle = skyGrad;
    ctx.fillRect(0, 0, 1024, 280);

    // Distant soft haze & sun glow
    const sunGrad = ctx.createRadialGradient(512, 220, 20, 512, 220, 360);
    sunGrad.addColorStop(0, 'rgba(255, 245, 220, 0.6)');
    sunGrad.addColorStop(0.5, 'rgba(230, 180, 130, 0.3)');
    sunGrad.addColorStop(1, 'rgba(0, 0, 0, 0)');
    ctx.fillStyle = sunGrad;
    ctx.fillRect(0, 0, 1024, 280);

    // Foreground Dune Curves
    ctx.fillStyle = '#b8895b';
    ctx.beginPath();
    ctx.moveTo(0, 280);
    ctx.quadraticBezierTo(280, 230, 550, 290);
    ctx.quadraticBezierTo(820, 350, 1024, 260);
    ctx.lineTo(1024, 450);
    ctx.lineTo(0, 450);
    ctx.closePath();
    ctx.fill();

    ctx.fillStyle = '#8f5f36';
    ctx.beginPath();
    ctx.moveTo(0, 340);
    ctx.quadraticBezierTo(400, 290, 750, 380);
    ctx.lineTo(1024, 330);
    ctx.lineTo(1024, 450);
    ctx.lineTo(0, 450);
    ctx.closePath();
    ctx.fill();

    // Wanderer silhouette on dune crest
    ctx.fillStyle = '#1c1511';
    ctx.beginPath();
    ctx.arc(512, 275, 4, 0, Math.PI * 2);
    ctx.rect(510, 279, 4, 11);
    ctx.fill();

    const texture = new THREE.CanvasTexture(canvas);
    texture.minFilter = THREE.LinearFilter;
    texture.magFilter = THREE.LinearFilter;
    return texture;
  }

  // --- Seat Builders ---
  function createStandardSeatMesh() {
    const seatGroup = new THREE.Group();
    const cushions = [];

    // Cushion Base
    const cushionGeo = new THREE.BoxGeometry(0.50, 0.12, 0.48);
    const cushion = new THREE.Mesh(cushionGeo, velvetCrimsonMaterial);
    cushion.position.set(0, 0.42, 0);
    cushion.castShadow = true;
    cushion.receiveShadow = true;
    seatGroup.add(cushion);
    cushions.push(cushion);

    // Backrest
    const backGroup = new THREE.Group();
    backGroup.position.set(0, 0.44, 0.20);
    backGroup.rotation.x = THREE.MathUtils.degToRad(8.5);

    const backPadGeo = new THREE.BoxGeometry(0.48, 0.60, 0.12);
    const backPad = new THREE.Mesh(backPadGeo, velvetCrimsonMaterial);
    backPad.position.set(0, 0.30, 0);
    backPad.castShadow = true;
    backPad.receiveShadow = true;
    backGroup.add(backPad);
    cushions.push(backPad);

    const backShellGeo = new THREE.BoxGeometry(0.49, 0.61, 0.04);
    const backShell = new THREE.Mesh(backShellGeo, darkPlasticMaterial);
    backShell.position.set(0, 0.30, 0.07);
    backShell.castShadow = true;
    backGroup.add(backShell);

    const headrestGeo = new THREE.BoxGeometry(0.42, 0.16, 0.13);
    const headrest = new THREE.Mesh(headrestGeo, velvetCrimsonMaterial);
    headrest.position.set(0, 0.65, -0.01);
    headrest.castShadow = true;
    backGroup.add(headrest);
    cushions.push(headrest);

    seatGroup.add(backGroup);

    // Armrests
    [-0.28, 0.28].forEach((xPos) => {
      const strutGeo = new THREE.BoxGeometry(0.06, 0.34, 0.36);
      const strut = new THREE.Mesh(strutGeo, darkPlasticMaterial);
      strut.position.set(xPos, 0.43, 0.02);
      strut.castShadow = true;
      seatGroup.add(strut);

      const armPadGeo = new THREE.BoxGeometry(0.08, 0.045, 0.40);
      const armPad = new THREE.Mesh(armPadGeo, darkPlasticMaterial);
      armPad.position.set(xPos, 0.62, 0);
      seatGroup.add(armPad);
    });

    // Pedestal Post & Baseplate
    const postGeo = new THREE.CylinderGeometry(0.038, 0.038, 0.34, 12);
    const post = new THREE.Mesh(postGeo, metalPedestalMaterial);
    post.position.set(0, 0.17, 0.05);
    post.castShadow = true;
    seatGroup.add(post);

    return { group: seatGroup, cushions, isRecliner: false };
  }

  function createReclinerSeatMesh() {
    const seatGroup = new THREE.Group();
    const cushions = [];

    // Wider Plush Cushion
    const cushionGeo = new THREE.BoxGeometry(0.58, 0.15, 0.54);
    const cushion = new THREE.Mesh(cushionGeo, reclinerMaterial);
    cushion.position.set(0, 0.44, 0);
    cushion.castShadow = true;
    cushion.receiveShadow = true;
    seatGroup.add(cushion);
    cushions.push(cushion);

    // Extended Footrest
    const footrestGeo = new THREE.BoxGeometry(0.54, 0.08, 0.28);
    const footrest = new THREE.Mesh(footrestGeo, reclinerMaterial);
    footrest.position.set(0, 0.36, -0.36);
    footrest.rotation.x = THREE.MathUtils.degToRad(15);
    seatGroup.add(footrest);
    cushions.push(footrest);

    // Reclined Backrest (~14 degrees tilt)
    const backGroup = new THREE.Group();
    backGroup.position.set(0, 0.46, 0.24);
    backGroup.rotation.x = THREE.MathUtils.degToRad(14);

    const backPadGeo = new THREE.BoxGeometry(0.56, 0.66, 0.15);
    const backPad = new THREE.Mesh(backPadGeo, reclinerMaterial);
    backPad.position.set(0, 0.33, 0);
    backPad.castShadow = true;
    backGroup.add(backPad);
    cushions.push(backPad);

    const headrestGeo = new THREE.BoxGeometry(0.48, 0.18, 0.16);
    const headrest = new THREE.Mesh(headrestGeo, reclinerMaterial);
    headrest.position.set(0, 0.72, -0.01);
    headrest.castShadow = true;
    backGroup.add(headrest);
    cushions.push(headrest);

    seatGroup.add(backGroup);

    // Wide Comfort Armrests with Cup Holders
    [-0.34, 0.34].forEach((xPos) => {
      const armGeo = new THREE.BoxGeometry(0.12, 0.38, 0.48);
      const arm = new THREE.Mesh(armGeo, darkPlasticMaterial);
      arm.position.set(xPos, 0.46, 0.02);
      arm.castShadow = true;
      seatGroup.add(arm);

      const cupGeo = new THREE.CylinderGeometry(0.045, 0.040, 0.07, 16);
      const cup = new THREE.Mesh(cupGeo, metalPedestalMaterial);
      cup.position.set(xPos, 0.66, -0.18);
      seatGroup.add(cup);
    });

    return { group: seatGroup, cushions, isRecliner: true };
  }

  // Build complete 9 rows x 14 columns = 126 seats
  function buildAuditoriumSeats() {
    const rowLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
    const columnXCoords = [
      -3.80, -3.00, -2.20, // Block 1 (Cols 1-3)
      -2.20, -1.70, -1.20, -0.50, 0.30, 0.90, 1.50, 2.10, // Block 2 (Cols 4-11)
      3.30, 4.10, 4.90, // Block 3 (Cols 12-14)
    ];

    for (let r = 0; r < rowLabels.length; r++) {
      const rowLabel = rowLabels[r];
      const isReclinerRow = rowLabel === 'I';
      const rowZ = 5.42 + r * 0.875 + (isReclinerRow ? 0.88 : 0.0);
      const rowY = 0.5 + r * 0.38;

      for (let s = 1; s <= 14; s++) {
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

  function setupLighting() {
    // Ambient
    const ambientLight = new THREE.AmbientLight(0x181824, 0.65);
    scene.add(ambientLight);

    // Screen Directional Light with Soft Shadows
    const screenLight = new THREE.DirectionalLight(0xf5e8df, 1.25);
    screenLight.position.set(0, 4.5, 0.5);
    screenLight.target.position.set(0, 2.0, 10.0);
    screenLight.castShadow = true;
    screenLight.shadow.mapSize.width = 1024;
    screenLight.shadow.mapSize.height = 1024;
    screenLight.shadow.camera.near = 0.5;
    screenLight.shadow.camera.far = 28.0;
    screenLight.shadow.camera.left = -8.0;
    screenLight.shadow.camera.right = 8.0;
    screenLight.shadow.camera.top = 9.0;
    screenLight.shadow.camera.bottom = -2.0;
    screenLight.shadow.bias = -0.0008;
    scene.add(screenLight);
    scene.add(screenLight.target);

    // Red Aisle Warm Accents
    const leftAisle = new THREE.PointLight(0xb91c1c, 0.5, 14.0);
    leftAisle.position.set(-6.5, 2.5, 10.0);
    scene.add(leftAisle);

    const rightAisle = new THREE.PointLight(0xb91c1c, 0.5, 14.0);
    rightAisle.position.set(6.5, 2.5, 10.0);
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

    const onEnd = () => { isDragging = false; };

    container.addEventListener('mousedown', (e) => onStart(e.clientX, e.clientY));
    window.addEventListener('mousemove', (e) => onMove(e.clientX, e.clientY));
    window.addEventListener('mouseup', onEnd);

    container.addEventListener('touchstart', (e) => {
      if (e.touches.length === 1) onStart(e.touches[0].clientX, e.touches[0].clientY);
    }, { passive: true });
    window.addEventListener('touchmove', (e) => {
      if (e.touches.length === 1) onMove(e.touches[0].clientX, e.touches[0].clientY);
    }, { passive: true });
    window.addEventListener('touchend', onEnd);
  }

  // --- Two-Stage Camera Animation Loop ---
  function animate(timestamp) {
    requestAnimationFrame(animate);

    if (cameraState.isTransitioning) {
      const elapsed = timestamp - cameraState.transitionStartTime;
      const progress = Math.min(elapsed / cameraState.transitionDuration, 1.0);
      const ease = 0.5 - Math.cos(progress * Math.PI) / 2; // easeInOut

      if (cameraState.transitionType === 'forward') {
        // Stage 1 (0 - 35%): Cross-fade / hold at overhead view showing mint seat
        // Stage 2 (35% - 100%): Smooth descent along curved path to eye level
        if (progress < 0.35) {
          const t1 = progress / 0.35;
          cameraState.currentPos.copy(cameraState.overheadPos);
          cameraState.currentLook.copy(cameraState.overheadLook);
        } else {
          const t2 = (progress - 0.35) / 0.65;
          const curveEase = 1.0 - Math.pow(1.0 - t2, 3); // cubic out

          // Curved path: arc height
          const arcHeight = Math.sin(t2 * Math.PI) * 1.5;

          cameraState.currentPos.lerpVectors(cameraState.overheadPos, cameraState.targetEyePos, curveEase);
          cameraState.currentPos.y += arcHeight;
          cameraState.currentLook.lerpVectors(cameraState.overheadLook, cameraState.targetLook, curveEase);
        }
      } else {
        // Reverse transition: smoothly return back up to overhead
        cameraState.currentPos.lerpVectors(cameraState.targetEyePos, cameraState.overheadPos, ease);
        cameraState.currentLook.lerpVectors(cameraState.targetLook, cameraState.overheadLook, ease);
      }

      cameraState.yaw *= (1.0 - ease);
      cameraState.pitch *= (1.0 - ease);

      if (progress >= 1.0) {
        cameraState.isTransitioning = false;
        if (cameraState.transitionType === 'forward') {
          sendToFlutter({ type: 'transitionCompleted', seatId: activeSeatId });
        } else {
          sendToFlutter({ type: 'reverseTransitionCompleted' });
        }
      }
    } else {
      // Look-around lerp
      cameraState.yaw += (cameraState.targetYaw - cameraState.yaw) * 0.18;
      cameraState.pitch += (cameraState.targetPitch - cameraState.pitch) * 0.18;
    }

    // Apply Camera Position & Rotation
    camera.position.copy(cameraState.currentPos);

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

  function sendToFlutter(data) {
    try {
      if (window.FlutterBridge && window.FlutterBridge.postMessage) {
        window.FlutterBridge.postMessage(JSON.stringify(data));
      }
    } catch (e) {
      console.warn('FlutterBridge error:', e);
    }
  }

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
      case 'startTwoStageTransition':
      case 'setCameraPose':
      case 'selectSeat': {
        if (msg.seatId) {
          highlightSelectedSeat(msg.seatId);
        }

        if (msg.cameraPosition && msg.lookAtTarget) {
          cameraState.targetEyePos.set(msg.cameraPosition.x, msg.cameraPosition.y, msg.cameraPosition.z);
          cameraState.targetLook.set(msg.lookAtTarget.x, msg.lookAtTarget.y, msg.lookAtTarget.z);
        }

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
