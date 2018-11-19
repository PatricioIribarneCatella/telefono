module Plotting

using DSP, FFTW
using Plots

export set_plot, plot_frec, plot_wave, plot_spectrogram

# Sets backend renderer - PyPlot
function set_plot()
	pyplot()
end

# Plots wave in time
function plot_wave(s, fs)

	x_axis = (0:(length(s) - 1))./fs

	# Plot it
	p = plot(x_axis, s,
		 title="Modem Dialing - fs: $fs",
		 xlabel="Time [s]",
		 legend=false)
	
	# Save it in .png
	savefig(p, "wave.png")
end

# Plots wave in frecuency
function plot_frec(s, fs)

	# FFT of the input wave
	X = abs.(fft(s))

	# Shift the returned spectrum
	Xshift = fftshift(X)

	# In Hertz
	x_axis = (0:(1/length(X)):1) .* fs

	# In Omega (w)
	x_axis_omega = (-1:(1/length(X)):1) .* fs

	# Find the middle of the x_axis
	# to get the first half of the returned
	# spectrum
	x_end = findfirst(x -> x >= (fs/2), x_axis)

	x_neg = findfirst(x -> x >= -(fs/2), x_axis_omega)
	x_pos = findfirst(x -> x >= (fs/2), x_axis_omega)

	# Frecuency plot
	p = plot(x_axis[1:x_end], X[1:x_end],
		 title="Modem Dialing Frecuency Domain",
		 xlabel="Freq [Hz]",
		 legend=false);
	
	# Save it in .png
	savefig(p, "wave-frec.png")

	# Omega plot
	p = plot(x_axis_omega[x_neg:x_pos], Xshift,
		 title="Modem Dialing Omega Frecuency Domain",
		 xlabel="Freq [w]",
		 legend=false);

	# Save it in .png
	savefig(p, "wave-frec-omega.png")
end

# Plots the spectrogram
function plot_spectrogram(s, fs, win=tukey(256, 0.5))

	# Transform it into a Vector
	s = vec(s)

	# Obtains the spectrogram
	spec = spectrogram(s, length(win), fs=fs, window=win)

	t, fr, pow = spec.time, spec.freq, spec.power

	# Rearrenge the negative frequencies
	neg_freq = findfirst(x -> x < 0, fr)

	if neg_freq !== nothing
		neg_pos = neg_freq - 1
		freq = [spec.freq[neg_freq:end]; spec.freq[1:neg_pos]]
		pow = [spec.power[neg_freq:end, :]; spec.power[1:neg_pos, :]]
	end

	# Plot it (HeatMap)
	hm = heatmap(t, fr, pow .+ eps() .|> log; seriescolor=:bluesreds,
		     title="Spectrogram", xlabel="Time [s]", ylabel="Freq [Hz]")

	# Save it in .png
	savefig(hm, "spec.png")
end

end # module

