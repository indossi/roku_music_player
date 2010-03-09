package app;

import java.io.*;
import java.util.*;

public class WmaMusic {
	private final String name = "WmaMusic";

	private File baseLocalDir;
	private MusicXml musicXml;
	
	private final String wmaSuffix = "wma";
	private final String mp3Suffix = "mp3";
	private final String albumArtPrefix = "AlbumArt_";
	private final String songChar = " ";
	
	public WmaMusic(String dir, MusicXml music) {
	    baseLocalDir = new File(dir);
		musicXml = music;	
	}
	
	public void process() {
		File artistDirFile, albumDirFile, songFile;
		File[] artistDirFiles, albumDirFiles, songFiles;
		File symArtistDirFile, symAlbumDirFile;
		Artist artist;
		Album album;
		Song song;
		String songTitle;
		ListIterator<Artist> artistIterator;
		int index;
						
		artistDirFiles = baseLocalDir.listFiles();
		for (int i = 0; i < artistDirFiles.length; i++) {
			artistDirFile = artistDirFiles[i];
			if (artistDirFile.isDirectory()) {
				
				if (artistDirFile.getName().contains("Unknown Artist"))
				    continue;
				
				artist = null;
				artistIterator = musicXml.artistsList.listIterator();
				while (artistIterator.hasNext()) {
					if (artistIterator.next().name.equals(artistDirFile.getName())) {
						artist = artistIterator.previous();
						break;
					}
				}
				 
				if (artist == null)
			        artist = new Artist(artistDirFile.getName());
			    artist.actualFilename = artistDirFile.getAbsolutePath();
			    artist.symFilename = musicXml.baseSymDir + "/" + artist.name
			        .replace(MusicXml.space, MusicXml.spaceReplacement)
			        .replace(MusicXml.pound, MusicXml.poundReplacement)
			        .replace(MusicXml.ampersand, MusicXml.ampersandReplacement);
			    symArtistDirFile = new File(artist.symFilename);
			    symArtistDirFile.mkdir();
			    
			    musicXml.artistsList.add(artist);
			    if (musicXml.verboseFlag)
			    	System.out.printf("%s: adding artist %s\n", name, artist.name);
			    
			    albumDirFiles = artistDirFile.listFiles();
			    for (int j = 0; j < albumDirFiles.length; j++) {
			    	albumDirFile = albumDirFiles[j];
			    	
			    	if (!albumDirFile.isDirectory())
			    		continue;

			    	album = new Album(albumDirFile.getName());
			        symAlbumDirFile = new File(artist.symFilename + "/" +
			        	album.name
			        	.replace(MusicXml.space, MusicXml.spaceReplacement)
			        	.replace(MusicXml.pound, MusicXml.poundReplacement)
			        	.replace(MusicXml.ampersand, MusicXml.ampersandReplacement));
			        symAlbumDirFile.mkdir();

			        musicXml.albumsList.add(album);
			    	artist.albumList.add(album);

				    if (musicXml.verboseFlag)
                        System.out.printf("%s: adding album %s to artist %s\n", name,
			    	        album.name, artist.name);
			    	
			    	songFiles = albumDirFile.listFiles();
			    	for (int n = 0; n < songFiles.length; n++) {
			    		songFile = songFiles[n];
			    	    songTitle = songFile.toString();
			    	    
			    		if (songTitle.contains(albumArtPrefix)) {
			    			album.actualArtFilename = songTitle;
			    			album.actualArtUrl = musicXml.baseRemoteUrl + songTitle;
			    			album.symArtFilename = symAlbumDirFile.getAbsolutePath() +
			    			    songTitle.substring(songTitle.lastIndexOf("/"));			    			    
			    			album.symArtUrl = musicXml.hostUrl + symAlbumDirFile.getAbsolutePath() +
			    			    songTitle.substring(songTitle.lastIndexOf("/"));
			    			musicXml.createSymLink(album.actualArtFilename, album.symArtFilename);
			    			
			    			continue;
			    		}
			    		
			    		if (songTitle.contains("[Silence]"))
			    			continue;
			    		
			    		if (songTitle.endsWith(wmaSuffix) ||
			    			songTitle.endsWith(mp3Suffix)) {
			    			
			    			song = new Song();
			    			song.name = songTitle.substring(songTitle.lastIndexOf('/') + 1);			    		    song.actualFilename = songTitle;
			    		    song.actualUrl = musicXml.baseRemoteUrl + songTitle;
			    		    song.symFilename = symAlbumDirFile.getAbsolutePath() + "/" +
			    		        song.name
			    		        .replaceAll(MusicXml.space, MusicXml.spaceReplacement)
			    		        .replaceAll(MusicXml.pound, MusicXml.poundReplacement)
			    		        .replaceAll(MusicXml.ampersand, MusicXml.ampersandReplacement);
			    		     
			    		    song.symUrl = musicXml.hostUrl + song.symFilename;
			    		    song.trackId = Integer.parseInt(song.name.substring(0, song.name.indexOf(songChar)));
			    		    song.format = songTitle.endsWith(wmaSuffix) ? wmaSuffix : mp3Suffix;
			    		    song.name = song.name.substring(song.name.indexOf(songChar) + 1,
			    		    	song.name.indexOf(wmaSuffix) - 1);
			    		    song.album = album;
			    		    song.artist = artist;
			    			song.length = 5 * 60;  //XXX need to determine real length
			    		    
						    if (musicXml.verboseFlag)
                                System.out.printf("%s: adding song %s to album %s\n", name,
							        song.name, album.name);
				    			
			    			musicXml.createSymLink(songTitle, song.symFilename);
    
			    			for (index = 0; index < album.songList.size(); index++) {
			    			    if (song.trackId < album.songList.get(index).trackId)
			    			    	break;
			    			}
			    			album.songList.add(index, song);
			    			musicXml.songsList.add(song);
			    		}
			    	}
			    }
			    Collections.sort(artist.albumList);
			}
		}
	}
}