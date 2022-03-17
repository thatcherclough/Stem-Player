from pytube import YouTube
import os

def download(url, file_name, output_dir):
    page = YouTube(url)
    video = page.streams.filter(only_audio=True).first()
    out_file = video.download(output_path=output_dir)
    new_file = output_dir + "/" + file_name + '.mp3'
    os.rename(out_file, new_file)
    return new_file
