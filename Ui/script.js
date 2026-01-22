const localSongs = [
    { id: 1, title: "七里香", artist: "周杰伦", cover: "https://picsum.photos/400/400?random=1" },
    { id: 2, title: "Imagine", artist: "John Lennon", cover: "https://picsum.photos/400/400?random=2" },
    { id: 3, title: "Stay", artist: "The Kid LAROI", cover: "https://picsum.photos/400/400?random=3" },
    { id: 4, title: "Blinding Lights", artist: "The Weeknd", cover: "https://picsum.photos/400/400?random=4" }
];

let state = { currentSong: localSongs[0], isPlaying: false, activeTab: 'library' };

function init() {
    switchTab('library');
    updateUI();
}

function switchTab(tab) {
    state.activeTab = tab;
    const content = document.getElementById('main-content');
    const title = document.getElementById('nav-title');
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    document.getElementById(`nav-${tab}`).classList.add('active');

    if (tab === 'library') {
        title.innerText = "乐库";
        content.innerHTML = localSongs.map(s => `
            <div class="flex items-center gap-4 px-6 py-3 tap-effect" onclick="selectSong(${s.id})">
                <img src="${s.cover}" class="w-14 h-14 rounded-xl object-cover">
                <div><h3 class="font-bold text-gray-800 text-sm">${s.title}</h3><p class="text-[10px] text-gray-400 uppercase">${s.artist}</p></div>
            </div>
        `).join('');
    } else if (tab === 'queue') {
        title.innerText = "播放列表";
        content.innerHTML = `<div class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">正在播放队列 (${localSongs.length})</div>` +
        localSongs.map(s => `
            <div class="flex items-center gap-4 px-6 py-3 ${s.id === state.currentSong.id ? 'bg-blue-50' : ''}" onclick="selectSong(${s.id})">
                <div class="text-[10px] font-mono w-4">${s.id}</div>
                <div class="flex-grow"><h3 class="font-bold text-sm ${s.id === state.currentSong.id ? 'text-blue-500' : ''}">${s.title}</h3></div>
                <div class="text-[10px] text-gray-300">03:45</div>
            </div>
        `).join('');
    } else if (tab === 'playlists') {
        title.innerText = "歌单";
        content.innerHTML = `
            <div class="p-6 grid grid-cols-2 gap-4">
                <div class="aspect-square bg-gray-50 rounded-3xl flex flex-col items-center justify-center border-2 border-dashed border-gray-200 text-gray-400 text-xs font-bold"><span>+ 新建歌单</span></div>
                <div class="aspect-square bg-red-50 rounded-3xl flex flex-col p-4">
                    <span class="text-2xl mb-auto">❤️</span>
                    <span class="font-bold text-sm">我喜欢的</span>
                    <span class="text-[10px] text-red-300">42 首歌曲</span>
                </div>
            </div>`;
    } else if (tab === 'settings') {
        title.innerText = "设置";
        content.innerHTML = `
            <div class="settings-group-title">扫描</div>
            <div class="setting-row"><span class="setting-label">自动更新乐库</span><div class="toggle active" onclick="this.classList.toggle('active')"></div></div>
            <div class="settings-group-title">音频</div>
            <div class="setting-row"><span class="setting-label">均衡器</span><span class="text-blue-500 text-sm">流行 ❯</span></div>
            <div class="setting-row"><span class="setting-label">高品质音频</span><div class="toggle" onclick="this.classList.toggle('active')"></div></div>
        `;
    }
}

function openFullPlayer() { document.getElementById('player-screen').classList.add('active'); }
function closeFullPlayer() { document.getElementById('player-screen').classList.remove('active'); }

function selectSong(id) {
    state.currentSong = localSongs.find(s => s.id === id);
    updateUI();
    if(state.activeTab === 'queue') switchTab('queue');
}

function updateUI() {
    const s = state.currentSong;
    document.getElementById('mini-title').innerText = s.title;
    document.getElementById('mini-artist').innerText = s.artist;
    document.getElementById('mini-art').src = s.cover;
    document.getElementById('full-title').innerText = s.title;
    document.getElementById('full-artist').innerText = s.artist;
    document.getElementById('full-art').src = s.cover;
}

function togglePlay(event) {
    event.stopPropagation();
    state.isPlaying = !state.isPlaying;
    document.getElementById('play-icon').innerHTML = state.isPlaying ?
        '<path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>' : '<path d="M8 5v14l11-7z"/>';
    document.getElementById('detail-play-icon').innerText = state.isPlaying ? '⏸' : '▶';
}

function showSearchBar() {
    document.getElementById('search-bar-inline').classList.toggle('hidden');
}

init();