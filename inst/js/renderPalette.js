import palettes from './palettes.json';

export function renderPalette(data) {
  const palObj = palettes.find(p => p.palette === data.value);
  if (!palObj) return data.label;
  const colors = palObj.colors;
  
  const swatch = '<span class="pal-block">' +
    colors.map(c => `<span class="pal-square" style="background:${c};"></span>`).join('') +
    '</span>';
    
  return swatch + ' ' + data.label;
}
