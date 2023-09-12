<h3>正如你所见，这是我部署在GitHub Page上的笔记本，目前只有一点x86汇编的学习笔记</h3>

------

[>>x86汇编笔记	](/assembly_language/)



<p style="font-size: 20px">但你难得来一趟，总不能让你空手而归。这样吧，你喜欢听音乐吗。这首李健的《风吹麦浪》送给你</p>

<audio id="musicPlayer" controls>
  <source src="./风吹麦浪.mp3" type="audio/mp3">
  Your browser does not support the audio element.
</audio>

<br>
<p>好吧，你说你不想听。那就悄悄告诉你一个秘密，这整个网页都是用markdown渲染的，包括侧边栏和上面的播放器。有没有觉得吃惊。</p>
<p>好吧，你觉得这一点也不好玩。那再悄悄告诉你一个我刚发现的秘密，markdown它支持Html和CSS样式，虽然CSS样式只有使用预览或在网页上才能看到，在typora这样的编辑器里不会渲染。你看到的下面这个按钮，就用上了CSS样式。</p>

<style>
    .button {
      background-color: blue;
      color: white;
      padding: 10px 20px;
      border: none;
      cursor: pointer;
      transition: background-color 0.3s ease;
    }

    .button.clicked {
      background-color: red;
    }
</style>

<button id="myButton" class="button">按钮</button>

<script>
  var button = document.getElementById("myButton");
  button.addEventListener("click", function() {
    button.classList.add("clicked");
  });
</script>

<p>不过很可惜，markdown并不支持javascript，不然当你点击这个按钮的时候，它应该会在0.3秒内变成红色。<br>
也许你可以自己试试看用浏览器调试，实现这个功能？</p>

